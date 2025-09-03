# Ambiente Docker para aplicações Laravel.

Este projeto configura um ambiente local com um banco de dados Oracle 12c Enterprise Edition e uma imagem do PHP 8.2 CLI usando Docker e Docker Compose.

## Instalação

Faça o Fork deste repositório (Página principal do repo, botão Fork), alterando o nome para ```NOME-DO-SEU-PROJETO LARAVEL ENVIRONMENT``` e o path para ```<nome-do-seu-projeto>```. 

- Clone em sua máquina o repositório que você forkou.

```bash
git clone <url-do-repo-que-você-forkou>
```
- Entre na pasta criada
```bash
cd <nome-do-seu-projeto>
```

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- Um cliente SQL como [SQL Developer](https://www.oracle.com/tools/downloads/sqldev-downloads.html), [DBeaver](https://dbeaver.io/) ou [SQLTools no VSCode](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools)

---

## 📦 Imagens Docker Necessárias

Antes de subir o ambiente, baixe as imagens necessárias:

```bash
docker pull adordm/oracle-database-enterprise:12.2.0.1-slim
docker pull php:8.2-cli
```

Esses comandos irão baixar as imagens:
- **Oracle Database 12.2.0.1 (slim)**: versão leve do banco Oracle Enterprise.
- **PHP 8.2 CLI**: para executar scripts e testes em linha de comando com PHP.


## 🚀 Subindo o Ambiente

Execute o seguinte comando para iniciar os contêineres em segundo plano:
```bash
docker compose build
docker compose up
```
Esse comando irá:
- Criar e iniciar os containers definidos no docker-compose.yml.
- Iniciar o banco de dados Oracle em segundo plano.

## 🔐 Acessando o Banco de Dados Oracle

Para acessar o container do banco Oracle e definir uma senha para o sys
```bash
docker exec -it oracle_db bash
sqlplus / as sysdba
ALTER USER system IDENTIFIED BY oracle;
```
## 🧩 Conectando via DBeaver ou outro cliente SQL

Após subir o ambiente e garantir que o banco está ativo, conecte-se ao Oracle usando as credenciais abaixo:
- **Host**: localhost
- **Porta**: 1521
- **DB Name**: ORCLDB.localdomain
- **Usuário**: system
- **Senha**: oracle


## 📝 Notas

A primeira inicialização do banco Oracle pode levar alguns minutos até que ele esteja totalmente disponível.
Verifique os logs com:
```bash
docker logs -f oracle_db
```

🛠️ Possíveis Comandos Úteis

- Parar os containers:
```bash
docker compose down
```
- Verificar se o banco está "ready":
```bash
docker exec -it oracle_db tail -f /opt/oracle/alert.log
```
