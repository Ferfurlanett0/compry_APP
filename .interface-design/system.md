# Compry — sistema de interface

## Direção

Central de operações para passagem de listas entre quem solicita e quem compra. A interface deve responder, sem interpretação: quem está responsável, em qual etapa a lista está e qual é a próxima ação.

## Assinatura

Trilho de passagem de bastão em quatro etapas: Montando → Enviada → Em compra → Concluída. O mesmo padrão aparece nas listas, no detalhe e no histórico.

## Tokens

- Fundo papel: `#F5F7F2`
- Superfície: `#FFFFFF`
- Tinta: `#131B14`
- Texto secundário: `#4C584E`
- Texto terciário: `#626E64`
- Contorno suave: `#C5CFC2`
- Verde ação: `#176B3A`
- Verde profundo: `#163E26`
- Âmbar de atenção: `#A85F00`
- Vermelho de urgência: `#A13B31`
- Base de espaçamento: 4 px; ritmo principal: 8/12/16/24/32 px
- Profundidade: mudanças discretas de superfície e divisores; sombra apenas em elementos flutuantes
- Tipografia: Roboto empacotada no app, no máximo quatro tamanhos principais e dois pesos

## Padrões

- Alvos de toque com no mínimo 48 px.
- O avatar salvo aparece no cabeçalho; iniciais são apenas o estado de fallback.
- Ação principal na zona inferior do polegar.
- Linhas operacionais planas em vez de vários cartões iguais.
- Horários exibidos no fuso local do dispositivo, sempre com data e hora quando houver risco de ambiguidade.
- Listas enviadas mostram separadamente `Enviada` e `Recebida`.
- Navegação do funcionário: Listas, Histórico, Perfil.
- Navegação do administrador: Central, Histórico, Avisos, Perfil.
- Conteúdo limitado a 720 px em telas largas; em celulares usa toda a largura respeitando SafeArea.
- Layout-base validado a partir de 320 px de largura e com escala de texto até 140%.

