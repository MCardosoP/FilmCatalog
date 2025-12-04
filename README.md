# Catálogo de Filmes
Aplicativo mobile desenvolvido em Flutter, com o objetivo de implementar um catálogo de filmes, permitindo cadastrar, listar, editar e excluir (CRUD) filmes. 
A arquitetura utilizada foi o **MVC (Model-View-Controller)**, com integração de banco de dados local e autenticação de usuários via **Hive**.
Foi utilizada a API do OMDb, que fornece informações sobre filmes, e o recurso nativo da câmera, que pode ser usada para alterar o banner de cada entrada de filme.

---

## Integrantes do Grupo
- Matheus Cardoso Pinto

---

## Funcionalidades do Projeto

### Sistema de Autenticação
- Cadastro de usuários com username e senha
- Login com validação de credenciais
- Logout
- Senha criptografada (SHA-256)
- Sessão persistente
- Isolamento de dados por usuário

### Catálogo de Filmes
- Adicionar filmes
- Visualizar filmes
- Detalhes do filme
- Editar filmes
- Deletar filmes

### Busca de Filmes (API Externa)
- Integração com OMDb API
- Interface de busca

### Recursos Nativos
- Câmera
- Armazenamento Local
- Permissões

---

## Como executar o projeto

### Pré-requisitos
- Flutter SDK instalado -> https://docs.flutter.dev/get-started/install
- Emulador Android/iOS ou dispositivo físico conectado

### Passos
1. Clone este repositório -> git clone https://github.com/MCardosoP/FilmCatalog.git
2. Acesse a pasta onde o clone está localizado
3. Instale as dependências -> flutter pub get
4. Gere os adapters Hive (se necessário) -> dart run build_runner build

Em dispositivos móveis:

5. Execute o aplicativo -> flutter run
6. Escolha o dispositivo onde o aplicativo deve ser executado

Na web:

5. Gere a build web -> flutter build web
6. Vá até a pasta gerada -> cd build/web
7. Rode o servidor local -> python -m http.server 8080
8. Acesse no navegador -> http://localhost:8080
