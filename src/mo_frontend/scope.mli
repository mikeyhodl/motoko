open Mo_types.Type

type val_kind = Declaration | FieldReference
type val_env = (typ * Source.region * val_kind) Env.t
type lib_env = Mo_types.Type.typ Env.t
type typ_env = con Env.t
type con_env = ConSet.t
type fld_src_env = Mo_types.Field_sources.srcs_map

(* TODO: make this a record *)
type mixin_env = (Mo_def.Syntax.import list * Mo_def.Syntax.pat * Mo_def.Syntax.dec_field list * typ) Env.t
and obj_env = scope Env.t  (* internal object scopes *)
and scope =
  { val_env : val_env;
    lib_env : lib_env;
    typ_env : typ_env;
    con_env : con_env;
    obj_env : obj_env;
    mixin_env : mixin_env;
    fld_src_env : fld_src_env;
  }
and t = scope

val empty : scope
val adjoin : scope -> scope -> scope

val adjoin_val_env : scope -> val_env -> scope
val lib : string -> typ -> scope
val mixin : string -> Mo_def.Syntax.import list * Mo_def.Syntax.pat * Mo_def.Syntax.dec_field list * typ -> scope
