## 0. Get a local postgres instance

1. `docker pull postgres`
1. `docker run --rm --name pg-docker -e POSTGRES_PASSWORD=Postgres1234 -d -p 5432:5432 -v /Users/adam.neumann/workspace/bors-ng/pgdata:/var/lib/postgresql/data postgres`
1. `mix deps.get`

### Migrate DB

1. `mix ecto.create`
1. `mix ecto.migrate`

## 1. Launch REPL

`./scripts/repl`

## 2. Imports

```
alias BorsNG.GitHub
alias BorsNG.GitHub.ServerMock
alias BorsNG.Database
```

## 3. Stub GitHub responses

```
ServerMock.put_state(%{
  {:installation, 91} => %{ repos: [
    %GitHub.Repo{
      id: 14,
      name: "test/repo",
      owner: %{
        id: 6,
        login: "bors-fanboi",
        avatar_url: "data:image/svg+xml,<svg></svg>",
        type: :user
      }}
  ] },
  {{:installation, 91}, 14} => %{
    branches: %{},
    commits: %{},
    comments: %{1 => []},
    pulls: %{
      1 => %GitHub.Pr{
        number: 1,
        title: "Test",
        body: "Mess",
        state: :open,
        base_ref: "master",
        head_sha: "00000001",
        user: %GitHub.User{
          id: 6,
          login: "bors-fanboi",
          avatar_url: "data:image/svg+xml,<svg></svg>"}}},
    pr_commits: %{
      1 => [
        %GitHub.Commit{
          sha: "00000001",
          author_name: "Bors Fanboi",
          author_email: "bors-fanboi@example.com"}
      ] },
    statuses: %{},
    collaborators: [],
    files: %{}}})
```

## 4. Trigger GitHub web hooks

```
BorsNG.WebhookController.do_webhook(%{
  body_params: %{
    "installation" => %{ "id" => 91 },
    "sender" => %{
      "id" => 6,
      "login" => "bors-fanboi",
      "avatar_url" => "" },
    "action" => "created" }}, "github", "installation")
```

## 5. Seed DB

1. http://localhost:8000/seed
1. Manually become admin via `psql` and `update users set is_admin = true;`


## 6. See project

1. visit http://localhost:8000/repositories/1
