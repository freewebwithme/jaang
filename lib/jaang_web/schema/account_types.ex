defmodule JaangWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation

  alias Jaang.Account.Accounts
  alias JaangWeb.Resolvers.{AccountResolver, ProfileResolver}
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias JaangWeb.Schema.Middleware

  object :account_mutations do
    @desc "Log in an user"
    field :log_in, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&AccountResolver.log_in/3)
    end

    @desc "Register an user"
    field :sign_up, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:password_confirmation, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))

      resolve(&AccountResolver.sign_up/3)
    end

    @desc "Reset password"
    field :reset_password, :simple_response do
      arg(:email, non_null(:string))

      resolve(&AccountResolver.reset_password/3)
    end

    @desc "Send confirmation email from Flutter"
    field :resend_confirmation_email, :simple_response do
      arg(:user_token, non_null(:string))

      resolve(&AccountResolver.resend_confirmation_email/3)
    end

    # @desc "Google Sign in"
    # field :google_signin, :session do
    #  arg(:email, non_null(:string))
    #  arg(:display_name, :string)
    #  arg(:photo_url, :string)

    #  resolve(&AccountResolver.google_signIn/3)
    # end

    @desc "Google Sign in using idToken"
    field :google_signin_with_id_token, :session do
      arg(:id_token, non_null(:string))

      resolve(&AccountResolver.google_signIn_with_id_token/3)
    end

    @desc "Log out"
    field :log_out, :session do
      arg(:token, :string)
      middleware(Middleware.Authenticate)

      resolve(&AccountResolver.log_out/3)
    end

    @desc "Verify session token from client"
    field :verify_token, :session do
      arg(:token, non_null(:string))

      resolve(&AccountResolver.verify_token/3)
    end

    # Address
    @desc "Update address"
    field :update_address, :session do
      arg(:user_token, non_null(:string))
      arg(:recipient, non_null(:string))
      arg(:address_id, non_null(:string))
      arg(:address_line_one, :string)
      arg(:address_line_two, :string)
      arg(:business_name, :string)
      arg(:zipcode, :string)
      arg(:city, :string)
      arg(:state, :string)
      arg(:instructions, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.update_address/3)
    end

    @desc "Change default address"
    field :change_default_address, :session do
      arg(:user_token, non_null(:string))
      arg(:address_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.change_default_address/3)
    end

    @desc "Add a new address"
    field :add_address, :session do
      arg(:user_token, non_null(:string))
      arg(:recipient, non_null(:string))
      arg(:address_line_one, non_null(:string))
      arg(:address_line_two, :string)
      arg(:business_name, :string)
      arg(:zipcode, non_null(:string))
      arg(:city, non_null(:string))
      arg(:state, non_null(:string))
      arg(:instructions, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.add_address/3)
    end

    @desc "Delete address"
    field :delete_address, :session do
      arg(:user_token, non_null(:string))
      arg(:address_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.delete_address/3)
    end

    @desc "Update profile information"
    field :update_profile, :session do
      arg(:user_token, non_null(:string))
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:phone, :string)
      arg(:photo_url, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.update_profile/3)
    end
  end

  object :user do
    field :id, :id
    field :stripe_id, :string
    field :email, :string
    field :confirmed_at, :string
    field :profile, :profile, resolve: dataloader(Accounts)
    field :addresses, list_of(:address), resolve: dataloader(Accounts)
  end

  object :session do
    field :user, :user
    field :token, :string
    field :expired, :boolean, default_value: false
  end

  object :profile do
    field :first_name, :string
    field :last_name, :string
    field :photo_url, :string

    field :phone, :string do
      resolve(fn parent, _, _ ->
        phone_number = Map.get(parent, :phone)

        cond do
          is_nil(phone_number) || phone_number == "" ->
            {:ok, phone_number}

          true ->
            area_code = String.slice(phone_number, 0, 3)
            head = String.slice(phone_number, 3, 3)
            tail = String.slice(phone_number, 6, 4)
            formatted = "(#{area_code})#{head}-#{tail}"
            {:ok, formatted}
        end
      end)
    end

    field :store_id, :id
  end

  object :address do
    field :id, :id
    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string
    field :default, :boolean
    field :distance, :distance, resolve: dataloader(Accounts)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Accounts, Accounts.data())

    Map.put(ctx, :loader, loader)
  end
end
