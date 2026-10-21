# 🧪 LabJura — Stack Integrada de Gestão Laboratorial

Arquitetura de microsserviços open source para gestão de **Patrimônio/Calibrações (GLPI)**, **Estoque de Reagentes/FEFO (InvenTree)** e **Atendimento ao Paciente com SLA de 3 Minutos (Chatwoot)**, orquestrada via **n8n**.

---

## 🏛️ Visão Geral da Arquitetura

```
┌────────────────────────────────────────────────────────────────────────┐
│                          LABORATÓRIO CLÍNICO                           │
├────────────────────┬─────────────────────────────┬─────────────────────┤
│ 1. ATENDIMENTO     │ 2. PATRIMÔNIO & CALIBRAÇÃO  │ 3. ESTOQUE & REAGENT│
│                    │                             │                     │
│ Chatwoot           │ GLPI                        │ InvenTree           │
│ Porta :3000        │ Porta :8080                 │ Porta :8081         │
│ • WhatsApp/Omni    │ • Inventário de Ativos      │ • Controle Lotes    │
│ • SLA 3 minutos    │ • Calibrações ANVISA/PALC   │ • Validades FEFO    │
│ • Multiatendentes  │ • Ordens de Manutenção      │ • QR Code Mobile    │
└────────────────────┴─────────────────────────────┴─────────────────────┘
                                  ▲
                                  │ APIs REST / Webhooks
                                  ▼
      ┌────────────────────────────────────────────────────────────┐
      │                 n8n Orquestrador (Na VPS)                  │
      │  • Auto-resposta instantânea e watchdog de SLA (< 3 min)   │
      │  • Monitoramento diário de reagentes vencendo (FEFO)       │
      │  • Alertas preventivos de calibração para eng. clínica     │
      └────────────────────────────────────────────────────────────┘
```

---

## 🚀 Como Executar Localmente

### 1. Pré-requisitos
- Docker & Docker Compose instalados.
- Git.

### 2. Configurar o Ambiente
Copie o arquivo de exemplo caso deseje customizar portas ou senhas:
```bash
cp .env.example .env
```

### 3. Subir os Containers
```bash
docker compose up -d
```

### 4. Acessos Locais

| Serviço | URL Local | Credenciais Padrão |
| :--- | :--- | :--- |
| **GLPI** | [http://localhost:8080](http://localhost:8080) | Usuário: `glpi` \| Senha: `glpi` |
| **InvenTree** | [http://localhost:8081](http://localhost:8081) | Usuário: `admin` \| Senha: `admin_labjura_2026` |
| **Chatwoot** | [http://localhost:3000](http://localhost:3000) | Primeiro acesso cria o usuário Administrador |

---

## 🌐 URLs de Produção (VPS com SSL HTTPS)

| Serviço | URL de Produção | Finalidade | Credenciais Iniciais |
| :--- | :--- | :--- | :--- |
| **GLPI** | [https://patrimonio.it4b.inf.br](https://patrimonio.it4b.inf.br) | Patrimônio, Equipamentos & Calibração | Usuário: `glpi` \| Senha: `glpi` |
| **InvenTree** | [https://estoque.it4b.inf.br](https://estoque.it4b.inf.br) | Estoque Laboratorial, Lotes & FEFO | Usuário: `admin` \| Senha: `68ddc58c5ba73f71cbf75b1a` |
| **Chatwoot** | [https://chat.it4b.inf.br](https://chat.it4b.inf.br) | Atendimento Omnichannel (SLA 3 Min) | Cadastro do Administrador no 1º acesso |

---

## 📂 Estrutura do Repositório

```
LabJura/
├── .env.example                    # Template de variáveis para VPS e Local
├── .gitignore                      # Protege senhas, volumes e dados de produção
├── docker-compose.yml              # Orquestrador local/produção da stack
├── DEPLOY_VPS.md                   # Guia passo a passo de subida para GitHub e VPS
├── scripts/
│   └── init-multi-postgres.sh      # Inicialização automática de múltiplos bancos
├── glpi/                           # Mapeamento de arquivos, plugins e configs GLPI
├── inventree/                      # Dados e mídias de estoque do InvenTree
├── chatwoot/                       # Storage de conversas e anexos do Chatwoot
└── workflows-n8n/                  # Fluxos prontos para importar no n8n da VPS
    ├── 01_sla_3min_chatwoot_triagem.json
    ├── 02_inventree_alerta_fefo_estoque.json
    └── 03_glpi_preventiva_calibracao.json
```

---

## 🔄 Fluxos de Integração no n8n

Os arquivos na pasta `workflows-n8n/` estão prontos para importação no n8n que já roda na sua VPS:

1. **`01_sla_3min_chatwoot_triagem.json`**:
   - Escuta o webhook do Chatwoot no primeiro contato do paciente.
   - Envia resposta imediata em menos de 10 segundos com menu de autoatendimento (laudos/preparo).
   - Ativa um temporizador watchdog (2.5 minutos): se nenhum atendente humano assumir a conversa, dispara alerta urgente na equipe.
2. **`02_inventree_alerta_fefo_estoque.json`**:
   - Executa diariamente às 07:00 da manhã.
   - Analisa reagentes vencidos e reagentes com vencimento em menos de 15 dias (regra FEFO).
   - Abre chamado automático com prioridade alta no GLPI para compras/reposição.
3. **`03_glpi_preventiva_calibracao.json`**:
   - Executa semanalmente às segundas-feiras às 08:00.
   - Mapeia equipamentos biomédicos pendentes de calibração periódica (ANVISA/PALC) e notifica os responsáveis.
