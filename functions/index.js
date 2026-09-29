const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

const db = getFirestore();

exports.onShoppingListUpdated = onDocumentUpdated(
  {
    document: 'shopping_lists/{listId}',
    region: 'southamerica-east1',
  },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const listId = event.params.listId;

    if (before.status !== 'PENDING' && after.status === 'PENDING') {
      if (!after.receivedAt) {
        await event.data.after.ref.update({
          receivedAt: FieldValue.serverTimestamp(),
        });
      }

      const admins = await db
        .collection('users')
        .where('role', '==', 'ADMIN')
        .get();

      const activeAdmins = admins.docs.filter(
        (admin) => admin.data().active !== false,
      );

      await notifyUsers({
        users: activeAdmins,
        title: 'Nova lista pronta para compra',
        body: `${after.createdByName || 'Um funcionário'} enviou “${after.title}”.`,
        type: 'LIST_SENT',
        listId,
      });
    }

    if (before.status !== 'FINISHED' && after.status === 'FINISHED') {
      const creator = await db.collection('users').doc(after.createdBy).get();
      if (creator.exists) {
        await notifyUsers({
          users: [creator],
          title: 'Compra concluída',
          body: `A lista “${after.title}” foi concluída.`,
          type: 'LIST_FINISHED',
          listId,
        });
      }
    }
  },
);

async function notifyUsers({ users, title, body, type, listId }) {
  if (!users.length) return;

  const batch = db.batch();
  const tokens = new Set();

  for (const user of users) {
    const notification = db
      .collection('notifications')
      .doc(`${type}_${listId}_${user.id}`);
    batch.set(notification, {
      userId: user.id,
      title,
      body,
      type,
      listId,
      route: `/lists/${listId}`,
      read: false,
      createdAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    const data = user.data();
    if (data.fcmToken) tokens.add(data.fcmToken);
    for (const token of data.fcmTokens || []) tokens.add(token);
  }

  await batch.commit();

  const tokenList = [...tokens];
  for (let start = 0; start < tokenList.length; start += 500) {
    await getMessaging().sendEachForMulticast({
      tokens: tokenList.slice(start, start + 500),
      notification: { title, body },
      data: {
        type,
        listId,
        route: `/lists/${listId}`,
      },
      android: { priority: 'high' },
    });
  }
}
