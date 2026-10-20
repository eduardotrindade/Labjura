# 🚀 Guia de Deploy: Local ➔ GitHub ➔ VPS

Este guia documenta o processo de versionamento do projeto **LabJura**, publicação no GitHub e deploy na sua **VPS** onde o **n8n** já está em operação.

---

## 1. Passo Local: Commit e Envio ao GitHub

1. Certifique-se de que o Git está configurado no seu terminal:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "seu-email@exemplo.com"
   ```

2. Crie um novo repositório privado no GitHub (ex: `https://github.com/SEU_USUARIO/labjura.git`).

3. No terminal do diretório `d:\Sistemas\sistemas\LabJura`, adicione os arquivos e faça o primeiro commit:
   ```bash
   git add .
   git commit -m "feat: stack completa LabJura (GLPI + InvenTree + Chatwoot + workflows n8n)"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/labjura.git
   git push -u origin main
   ```

---

## 2. Passo VPS: Clone e Inicialização

1. Acesse sua VPS via SSH:
   ```bash
   ssh root@SEU_IP_VPS
   ```

2. Navegue até o diretório onde organiza seus sistemas (ex: `/opt` ou `/var/www`):
   ```bash
   cd /opt
   git clone https://github.com/SEU_USUARIO/labjura.git
   cd labjura
   ```

3. Crie o arquivo `.env` de produção a partir do `.env.example`:
   ```bash
   cp .env.example .env
   nano .env
   ```
   > ⚠️ **Atenção:** Na VPS, altere as senhas padrão (`POSTGRES_PASSWORD`, `MARIADB_ROOT_PASSWORD`, `REDIS_PASSWORD`, `SECRET_KEY_BASE` e `INVENTREE_SECRET_KEY`) para senhas aleatórias seguras.

4. Dê permissão de execução ao script de inicialização do PostgreSQL:
   ```bash
   chmod +x scripts/init-multi-postgres.sh
   ```

5. Suba os containers na VPS:
   ```bash
   docker compose up -d
   ```

6. Verifique o status dos containers:
   ```bash
   docker compose ps
   ```

---

## 3. Passo n8n: Conectando os Workflows na VPS

Como o seu **n8n já está rodando na VPS**, a comunicação pode ocorrer tanto via rede interna Docker (se você colocar os containers na mesma network) quanto via URL de domínio com SSL.

### Como importar os fluxos:
1. Abra a interface web do seu **n8n**.
2. Clique em **Workflows** ➔ **Import from File**.
3. Selecione os 3 arquivos presentes na pasta `workflows-n8n/`:
   - `01_sla_3min_chatwoot_triagem.json`
   - `02_inventree_alerta_fefo_estoque.json`
   - `03_glpi_preventiva_calibracao.json`

### Obtenção dos Tokens de API:
1. **Chatwoot Bot Token**:
   - No Chatwoot, vá em **Configurações da Conta** ➔ **Agentes/Bots de Automação** ou crie um usuário bot e copie o Access Token.
2. **InvenTree API Token**:
   - No InvenTree, acesse com o usuário administrador, vá em **Configurações do Usuário** ➔ **API Tokens** ➔ **Criar Token**.
3. **GLPI REST API Token**:
   - No GLPI, vá em **Configurar** ➔ **Geral** ➔ aba **API**.
   - Habilite a API REST e crie um **Token de Aplicação (App-Token)**.
   - No seu usuário técnico, gere o **Token Pessoal (User-Token)**.

Insira essas variáveis de ambiente no n8n ou configure-as diretamente nos nós de cada fluxo.

---

## 4. Atualizações Futuras (CI/CD Simples)

Sempre que fizer alterações no ambiente local:
```bash
# No ambiente local:
git add .
git commit -m "ajuste: melhoria nos workflows n8n"
git push origin main

# Na VPS:
cd /opt/labjura
git pull origin main
docker compose up -d
```
