# checklist-app-front

Front-end da aplicação "Checklist App" — interface leve para criar, editar e gerenciar checklists. Este repositório contém a camada de apresentação (web) do projeto.

> Observação: este README foi criado conforme solicitado. Ajuste comandos, variáveis de ambiente e detalhes de acordo com a configuração real do projeto (ferramentas, scripts e dependências).

## Tecnologias (sugestão)
- JavaScript / TypeScript
- React / Preact / outro framework SPA (ajuste conforme o projeto)
- Vite / Create React App / Next.js (ajuste conforme o projeto)
- Tailwind / CSS / SASS (opcional)
- Axios / Fetch para comunicação com a API

## Requisitos
- Node.js >= 16.x
- npm >= 8.x ou yarn >= 1.22
- Git

## Instalação (local)
1. Clone o repositório:
```bash
git clone https://github.com/fedelamore/checklist-app-front.git
cd checklist-app-front
```

2. Instale dependências:
```bash
# usando npm
npm install

# ou usando yarn
yarn
```

3. Crie um arquivo de variáveis de ambiente a partir do exemplo:
```bash
cp .env.example .env
# editar .env conforme necessário (URL da API, chaves, etc.)
```

## Scripts úteis
(Os scripts abaixo são exemplos comuns — verifique o `package.json` real e ajuste conforme necessário.)
```bash
# rodar em desenvolvimento (hot-reload)
npm run dev

# build para produção
npm run build

# executar build (servidor estático)
npm run preview
# ou
npm run start

# rodar testes
npm run test

# lint
npm run lint
```

## Variáveis de ambiente
Crie `.env` baseado em `.env.example`. Variáveis comuns:
- VITE_API_URL (ou REACT_APP_API_URL) — URL base da API
- VITE_SENTRY_DSN — (opcional) DSN do Sentry
- NODE_ENV — ambiente (development / production)

A nomenclatura exata depende da ferramenta de build usada (Vite usa `VITE_`, Create React App usa `REACT_APP_`).

## Estrutura sugerida do projeto
- public/ — arquivos estáticos
- src/
  - assets/ — imagens, ícones
  - components/ — componentes reutilizáveis
  - pages/ — páginas/rotas
  - services/ — chamadas à API
  - hooks/ — hooks customizados
  - context/ — providers / estado global
  - styles/ — arquivos CSS / SASS
  - utils/ — utilitários e helpers
  - main.jsx / index.jsx — ponto de entrada

Ajuste conforme a organização real do repositório.

## Boas práticas
- Manter componentes pequenos e testáveis
- Documentar props importantes com PropTypes ou tipos TypeScript
- Escrever testes unitários para lógica crítica
- Lint e formatação automática (ESLint + Prettier)
- Versionar corretamente e usar PRs para mudanças significativas

## Deploy
- Build: `npm run build`
- Hospedar os arquivos buildados em serviços como Vercel, Netlify, Surge, GitHub Pages ou em um servidor estático (Nginx).
- Garanta que a variável de ambiente da API esteja apontando para o backend de produção.

## Contribuição
1. Fork e branch com nome descritivo: `feature/minha-nova-funcionalidade` ou `fix/corrige-bug`
2. Abra PR descrevendo mudanças e passos para testar
3. Mantenha commits pequenos e com mensagens claras

## Contato
- Maintainer: @fedelamore
- Repo: https://github.com/fedelamore/checklist-app-front

## Licença
Licença padrão (por exemplo MIT). Atualize conforme o arquivo LICENSE do repositório.

Se quiser, eu posso:
- adaptar o README ao stack exato do projeto (React/Vite/Next/etc) — envie o package.json ou diga qual stack está sendo usado;
- gerar um `.env.example` com as variáveis esperadas;
- criar badges e instruções de CI/CD (Vercel/GitHub Actions).