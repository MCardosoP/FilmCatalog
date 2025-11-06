# Catálogo de Filmes
Aplicativo mobile desenvolvido em Flutter, com o objetivo de implementar um catálogo de filmes, permitindo cadastrar, listar, editar e excluir (CRUD) filmes.
A arquitetura utilizada foi o **MVC (Model-View-Controller)**, com integração de banco de dados local e autenticação de usuários via **Hive**.

---

## Integrantes do Grupo
- Matheus Cardoso Pinto

---

## Funcionalidades

### Filmes
- Listar filmes cadastrados
- Exibir detalhes de cada filme
- Cadastrar novo filme
- Editar informações de um filme existente
- Excluir filme da lista

### Usuários
- Tela de login
- Tela de cadastro
- Armazenamento local de usuários
- Criptografia de senha
- Controle de sessão e logout 

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
