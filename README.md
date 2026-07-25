# ListaPro 🛒

**Sistema Inteligente de Gestão de Listas de Compras**

Aplicativo Android desenvolvido em Flutter para centralizar o fluxo de compras entre funcionários e o administrador de um estabelecimento, eliminando o uso do WhatsApp.

---

## 📱 Features do MVP

- ✅ Login com usuário e senha (sem cadastro pelo app)
- ✅ Perfis: Administrador e Funcionário
- ✅ Criar listas de compras com prioridade e categoria
- ✅ Adicionar itens com quantidade, unidade, marca, preço e observação
- ✅ Checklist em tempo real durante a compra
- ✅ Barra de progresso animada
- ✅ Funcionamento offline (Hive) com sincronização automática
- ✅ Push Notifications (FCM)
- ✅ Histórico permanente de listas
- ✅ Auditoria de eventos
- ✅ Tema claro e escuro (Material Design 3)

---

## 🏗️ Arquitetura

```
Flutter (UI)
    ↓ Riverpod
ViewModels
    ↓
Use Cases (regras de negócio)
    ↓
Repositories (interfaces)
    ↓
Data Sources
    ├── Firestore (online)
    └── Hive (offline)
```

**Stack:**
- Flutter 3.32+ / Dart 3.8+
- Clean Architecture + MVVM
- Riverpod (estado)
- GoRouter (navegação)
- Firebase (Auth, Firestore, FCM, Analytics, Crashlytics)
- Hive (banco offline)
- Material Design 3

---

## 🚀 Como configurar

### 1. Pré-requisitos
- Flutter 3.32+ instalado
- Android Studio / VS Code
- Conta Firebase

### 2. Criar projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Crie um novo projeto chamado **ListaPro**
3. Adicione um app Android com package name: `com.listapro.lista_pro`
4. Baixe o `google-services.json` e coloque em `android/app/`
5. Ative: Authentication, Firestore, Cloud Messaging, Analytics, Crashlytics

### 3. Configurar Firebase no Flutter
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=SEU_PROJETO_ID
```

### 4. Instalar dependências
```bash
flutter pub get
```

### 5. Criar usuários no Firebase
No Firebase Console, crie usuários em Authentication com email `usuario@listapro.app` e em Firestore em `users/{uid}`:
```json
{
  "name": "João Silva",
  "username": "joao",
  "role": "EMPLOYEE",
  "active": true
}
```

### 6. Rodar o app
```bash
flutter run
```

---

## 📁 Estrutura de Pastas

```
lib/
├── core/
│   ├── config/          (router, providers, constants)
│   ├── errors/          (failures)
│   ├── extensions/      (helpers)
│   ├── services/        (connectivity)
│   ├── theme/           (colors, typography, dimensions)
│   └── usecases/        (base interfaces)
├── features/
│   ├── authentication/  (login, logout, sessão)
│   ├── shopping_lists/  (CRUD listas e itens, checklist)
│   ├── history/         (histórico)
│   ├── notifications/   (FCM)
│   └── profile/         (perfil, logout)
└── shared/
    └── widgets/         (componentes reutilizáveis)
```

---

## 🔥 Firestore Security Rules

Deploy as regras:
```bash
firebase deploy --only firestore:rules
```

---

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Análise estática
flutter analyze
```

---

## 📋 Roadmap

| Versão | Features |
|--------|----------|
| **MVP 1.0** | Login, Listas, Itens, Checklist, Offline, Histórico, Notificações |
| **1.1** | Duplicar lista, Favoritos, Pesquisa avançada, PDF |
| **1.2** | Scanner código de barras, Imagens, Voz |
| **2.0** | Dashboard, IA, Estoque, ERP, Widgets, Wear OS |

---

*Desenvolvido com Flutter + Firebase • ListaPro © 2026*
