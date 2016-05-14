defmodule Murnau.Adapter.Telegram.Chat do
  @moduledoc """
  Represents a chat object.
  """
  @derive [Poison.Encoder]
  defstruct first_name: nil, id: nil, type: nil, username: nil, title: nil
  @type t :: %Murnau.Adapter.Telegram.Chat{first_name: binary,
                                           id: integer, type: binary, username: binary}
end

defmodule Murnau.Adapter.Telegram.User do
  @moduledoc """
  Represents a Telegram user or bot.
  """
  @derive [Poison.Encoder]
  defstruct id: nil, first_name: nil, username: nil
  @type t :: %Murnau.Adapter.Telegram.User{id: integer, first_name: binary, username: binary}
end
defmodule Murnau.Adapter.Telegram.Message do
  @moduledoc """
  Represents a Telegram message.
  """
  @derive [Poison.Encoder]
  defstruct message_id: nil, chat: nil, date: nil, from: nil, id: nil, text: nil
  @type t :: %Murnau.Adapter.Telegram.Message{message_id: integer,
                                              chat: Murnau.Adapter.Telegram.Chat.t,
                                              date: integer,
                                              from: Murnau.Adapter.Telegram.User.t,
                                              id: integer, text: binary}
end

defmodule Murnau.Adapter.Telegram.Update do
  @moduledoc """
  Represents a Telegram update.
  """
  @derive [Poison.Encoder]
  defstruct update_id: nil, message: nil
  @type t :: %Murnau.Adapter.Telegram.Update{update_id: integer,
                                             message: Murnau.Adapter.Telegram.Message.t}
end

defmodule Murnau.Adapter.Telegram.Result do
  @moduledoc """
  Represents a result.
  """
  @derive [Poison.Encoder]
  defstruct ok: nil, result: nil
end

defmodule Murnau.Adapter.Telegram.KeyboardButton do
  @moduledoc """
  Represents one button of the telegram reply keyboard.
  """
  @derive [Poison.Encoder]
  defstruct text: nil
  @type t :: %Murnau.Adapter.Telegram.KeyboardButton{text: binary}
end

defmodule Murnau.Adapter.Telegram.ReplyKeyboardMarkup do
  @moduledoc """
  Represents a custom keyboard with reply options, that telegram clients will show.
  """
  @derive [Poison.Encoder]
  defstruct keyboard: nil, resize_keyboard: nil, one_time_keyboard: nil, selective: nil
  @type t :: %Murnau.Adapter.Telegram.ReplyKeyboardMarkup{
    keyboard: [[]],
    resize_keyboard: boolean, one_time_keyboard: boolean, selective: boolean}
end
