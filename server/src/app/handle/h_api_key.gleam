import app/ctx
import app/handle/helper
import app/role
import app/struct/api_key
import gleam/bit_array
import gleam/crypto
import gleam/json
import gleam/string
import sql
import wisp

pub fn get_all(role: role.Role, ctx: ctx.Context) {
  use auth <- helper.try_res(role.match_host(role))
  use keys <- helper.guard_db(sql.get_api_keys(ctx.conn, auth.id))

  keys.rows
  |> api_key.GetAllApiKeysResponse
  |> api_key.encode_get_keys_response()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

pub fn add(role: role.Role, ctx: ctx.Context) {
  use auth <- helper.try_res(role.match_host(role))
  let gen =
    crypto.strong_random_bytes(48)
    |> bit_array.base64_encode(False)
    |> string.append("dfm_key_", _)
  use _ <- helper.guard_db(sql.add_api_key(
    ctx.conn,
    auth.id,
    gen |> bit_array.from_string(),
  ))
  api_key.CreateApiKeyResponse(api_key: gen)
  |> api_key.encode_create_api_key_response()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

pub fn purge_keys(role: role.Role, ctx: ctx.Context) {
  use auth <- helper.try_res(role.match_host(role))
  use _ <- helper.guard_db(sql.purge_api_keys(ctx.conn, auth.id))

  wisp.ok()
}
