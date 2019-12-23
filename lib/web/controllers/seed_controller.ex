defmodule BorsNG.SeedController do
  use BorsNG.Web, :controller

  alias BorsNG.GitHub
  alias BorsNG.GitHub.ServerMock

  # The actual handlers
  # Two-item ones have a project ID inputed
  # One-item ones don't

  def index(conn, _params) do
    seed_no_review_required_already_passed_ci
    initialize_installation

    render conn, "seed.html", something: []
  end

  def make_bors_merge_comment(conn, _params) do
    do_webhook_pr_comment

    render conn, "seed.html", something: []
  end

  defp seed_example do

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

    BorsNG.WebhookController.do_webhook(%{
      body_params: %{
        "installation" => %{ "id" => 91 },
        "sender" => %{
          "id" => 6,
          "login" => "bors-fanboi",
          "avatar_url" => "" },
        "action" => "created" }}, "github", "installation")
  end

  defp seed_no_review_required_already_passed_ci do
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
        comments: %{1 => ["bors merge"]},
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
        statuses: %{ # Statuses by commit
          "00000001" => %{ "circleci" => :ok }},
        collaborators: [
          %{ user: %GitHub.User{id: 23, login: "space", avatar_url: ""},
             perms: %{admin: true, push: true, pull: true}}
        ],
        files: %{ # Files by commit
          "00000001" => %{"bors.toml" => ~s/required_approvals = 0\npr_status = [ "circleci" ]/ }}}})
  end

  defp initialize_installation do
    BorsNG.WebhookController.do_webhook(%{
      body_params: %{
        "installation" => %{ "id" => 91 },
        "sender" => %{
          "id" => 6,
          "login" => "bors-fanboi",
          "avatar_url" => "" },
        "action" => "created" }}, "github", "installation")
  end

  defp do_webhook_pr_comment do
    BorsNG.WebhookController.do_webhook(%{
      body_params: %{
        "installation" => %{ "id" => 91 },
        "repository" => %{ "id" => 14 },
        "comment" => %{
          "user" => %{"id" => 23, "login" => "space", "avatar_url" => ""},
          "body" => "bors merge"
        },
        "pull_request" => %{
          "number" => 1,
          "title" => "Test",
          "body" => "Mess",
          "state" => "open",
          "base" => %{
            "ref" => "master",
            "repo" => %{
              "id" => 14
            }},
          "head" => %{
            "sha" => "00000001",
            "ref" => "00000001",
            "repo" => %{
              "id" => 14
            }},
          "user" => %{
            "id" => 6,
            "login" => "bors-fanboi",
            "avatar_url" => "data:image/svg+xml,<svg></svg>"},
          "merged_at" => nil},
        "action" => "created" }}, "github", "pull_request_review_comment")
  end
end
