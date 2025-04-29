defmodule ApiWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ApiWeb, :controller
      use ApiWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ApiWeb.Gettext
      alias ApiWeb.Router.Helpers, as: Routes
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: ApiWeb

      import Plug.Conn
      import ApiWeb.Gettext
      alias ApiWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/api_web/templates",
        namespace: ApiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      import ApiWeb.ErrorHelpers
      import ApiWeb.Gettext
      alias ApiWeb.Router.Helpers, as: Routes
    end
  end

  def json do
    quote do
      # Новый подход для JSON-представлений в Phoenix 1.7
      import Phoenix.Controller,
        only: [put_view: 2, view_module: 1, view_template: 1, json: 2]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      # Import basic rendering functionality
      import Phoenix.View, warn: false

      import ApiWeb.ErrorHelpers
      import ApiWeb.Gettext
      alias ApiWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
