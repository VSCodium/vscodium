# Contribuição

:+1::tada: Antes de mais nada, obrigado pelo seu tempo para contribuir! :tada::+1:

#### Tabela de Conteúdos

- [Código de Conduta](#code-of-conduct)
- [Reportar Erros](#reporting-bugs)
- [Efetuar Alterações](#making-changes)

## Código de Conduta

Este projeto e todos os participantes são governados pelo [VSCodium - Código de Conduta](CODE_OF_CONDUCT.md). Ao participar, esperasse que respeite este código.

## Reporte de Erros (Bugs)

### Antes de Submeter um Problema

Antes de criar relatórios de erros, por favor, consulte os problemas existentes e [a página de «Resolução de Problemas»](https://github.com/VSCodium/vscodium/blob/master/docs/troubleshooting.md) como pode descobrir que não precisa criar um.
Quando estiver a criar um relatório de erros, por favor, inclua o maior número de detalhes possível. Preencha o [modelo necessário](https://github.com/VSCodium/vscodium/issues/new?&labels=bug&&template=bug_report.md), a informação pedida para nos ajudar a resolver os problemas mais rapidamente.

## Efetuar Alterações

Se pretender efetuar alterações, por favor, leia [a página de «Criação»](./docs/howto-build.md).

### Criação de VSCodium

Para criar VSCodium, por favor, siga o comando encontrado na secção [`Scripts de Criação`](./docs/howto-build.md#build-scripts).

### Ataulização de correcções (<i>patches</i>)

Se pretender atualizar as correções existentes, por favor, siga a secção [`Processo de Atualização de Correção - Semi Automatático`](./docs/howto-build.md#patch-update-process-semiauto).

### Adicionar uma nova correção

- primeiro, tem de criar VSCodium
- depois utilize o comando `./dev/patch.sh <your patch name>`, para iniciar uma nova correção
- quando o <i>script</i> pausa em `Pressione qualquer tecla quando o conflito estiver resolvido...`, abra a diretoria `vscode` no **VSCodium**
- execute `npm run watch`
- execute `./script/code.sh`
- efetue as suas alterações
- pressione qualquer tecla para continuar o <i>script</i> `patch.sh`
