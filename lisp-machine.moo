;;#83882.("reserved") = {{"+", "prim_plus"}, {"-", "prim_sub"}, {"*", "prim_mul"}, {"/", "prim_div"}, {"=", "prim_eq"}, {"<", "prim_lt"}, {">", "prim_gt"}, {"<=", "prim_le"}, {">=", "prim_ge"}, {"if", ""}, {"lambda", ""}}
;;#83882.("key") = 0
;;#83882.("aliases") = {"Lisp Machine"}
;;#83882.("description") = "A clunky old machine. You can execute lisp code on it."
;;#83882.("object_size") = {3949, 1385798693}

@args #83882:"tokenize" none none none
@chmod #83882:tokenize rxd
@program #83882:tokenize
"Tokenize input.";
string = args[1];
parsed = $string_utils:subst(string, {{"(", " ( "}, {")", " ) "}});
tokenized = $string_utils:explode(parsed, " ");
return tokenized;
.

@args #83882:"tokens_to_ast" this none this
@program #83882:tokens_to_ast
"Takes an array of tokens and an optional index, returns the parsed sexp tree";
{tokens, ?idx = 1} = args;
if (idx > length(tokens))
  raise(E_INVARG, "Incomplete s expression");
endif
token = tokens[idx];
idx = idx + 1;
if (token == ")")
  raise(E_INVARG, "Unbalanced parentheses");
elseif (token == "(")
  ret = {};
  while ((idx <= length(tokens)) && (tokens[idx] != ")"))
    {subexp, idx} = this:tokens_to_ast(tokens, idx);
    ret = listappend(ret, subexp);
  endwhile
  if (idx > length(tokens))
    raise(E_INVARG, "Incomplete s expression");
  endif
  "Increment past the )";
  idx = idx + 1;
  return {ret, idx};
else
  try
    {success, val} = eval(("return " + token) + ";");
  except x (ANY)
    success = 0;
  endtry
  if (success)
    return {val, idx};
  else
    return {token, idx};
  endif
endif
.

@args #83882:"parse" this none this
@program #83882:parse
tokens = this:tokenize(@args);
return this:tokens_to_ast(tokens)[1];
.

@args #83882:"run exe*cute proc*ess" any on this
@chmod #83882:run rxd
@program #83882:run
this.location:announce(player.name, (" feeds a punch-card that says " + args[1]) + " into the Lisp Machine.");
player:tell(("You feed a punch-card that says " + args[1]) + " into the Lisp Machine.");
ret = this:eval(this:parse(args[1]), {});
this.location:announce_all(("The Lisp Machine spits out a new punch-card that says " + tostr(ret)) + ".");
.

@args #83882:"eval" this none this
@program #83882:eval
{exp, env} = args;
type = typeof(exp);
if (type == INT)
  return exp;
elseif (type == STR)
  if ($list_utils:iassoc(exp, this.reserved) != 0)
    "check for primitives &c";
    return exp;
  else
    "lookup in environment";
    found = 0;
    for i in [0..length(env) - 1]
      frame = env[length(env) - i];
      idx = $list_utils:iassoc(exp, frame);
      if (idx != 0)
        found = 1;
        val = frame[idx][2];
        break;
      endif
    endfor
    if (found == 0)
      raise(E_VARNF, "No such variable " + tostr(exp));
    endif
    return val;
  endif
elseif (type == LIST)
  "apply";
  if (typeof(exp[1]) == STR)
    if (exp[1] == "lambda")
      {largs, lbody} = {exp[2], exp[3]};
      return {"LAMBDA", largs, lbody, env};
    elseif (exp[1] == "LAMBDA")
      "compiled lambda";
      return exp;
    elseif (exp[1] == "if")
      pred = this:eval(exp[2], env);
      if (pred)
        return this:eval(exp[3], env);
      else
        return this:eval(exp[4], env);
      endif
    endif
  endif
  evalled = $list_utils:map_arg(this, "eval", exp, env);
  fn = evalled[1];
  if (typeof(fn) == STR)
    verbidx = $list_utils:iassoc(fn, this.reserved);
    if (verbidx == 0)
      raise(E_VERBNF, "No such primitive function " + tostr(fn));
    endif
    return this:(this.reserved[verbidx][2])(@evalled);
  elseif (typeof(fn) == LIST)
    frame = {};
    {l, largs, lbody, fnenv} = fn;
    if ((length(largs) + 1) != length(evalled))
      raise(E_ARGS, "Wrong number of args for function");
    endif
    for i in [1..length(largs)]
      frame = listappend(frame, {largs[i], evalled[1 + i]});
    endfor
    ret = this:eval(lbody, listappend(fnenv, frame));
    return ret;
  endif
endif
.

@args #83882:"prim_plus" this none this
@program #83882:prim_plus
res = 0;
for i in [2..length(args)]
  res = res + args[i];
endfor
return res;
.

@args #83882:"prim_eq" this none this
@program #83882:prim_eq
return args[2] == args[3];
.

@args #83882:"prim_sub" this none this
@program #83882:prim_sub
res = args[2];
for i in [3..length(args)]
  res = res - args[i];
endfor
return res;
.

@args #83882:"prim_mul" this none this
@program #83882:prim_mul
res = 1;
for i in [2..length(args)]
  res = res * args[i];
endfor
return res;
.

@args #83882:"prim_div" this none this
@program #83882:prim_div
res = args[2];
for i in [3..length(args)]
  res = res / args[i];
endfor
return res;
.

@args #83882:"prim_lt" this none this
@program #83882:prim_lt
return args[2] < args[3];
.

@args #83882:"prim_gt" this none this
@program #83882:prim_gt
return args[2] > args[3];
.

@args #83882:"prim_ge" this none this
@program #83882:prim_ge
return args[2] >= args[3];
.

@args #83882:"prim_le" this none this
@program #83882:prim_le
return args[2] <= args[3];
.

"***finished***
