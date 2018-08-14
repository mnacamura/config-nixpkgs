{
  html = ''
    --regex-HTML=/id=\"([a-zA-Z0-9-]+)\"/\1/i,identifiers/
    --regex-HTML=/class=\"([a-zA-Z0-9-]+)\"/\1/c,classes/
  '';

  julia = ''
    --langdef=Julia
    --langmap=Julia:.jl
    --regex-Julia=/^[ \t]*(abstract)[ \t]+([^ \t({[]+).*$/\2/a,abstract/
    --regex-Julia=/^[ \t]*(@with_kw[ \t]+)?(immutable)[ \t]+([^ \t({[]+).*$/\3/i,immutable/
    --regex-Julia=/^[ \t]*(@with_kw[ \t]+)?(type|typealias)[ \t]+([^ \t({[]+).*$/\3/t,type/
    --regex-Julia=/^[ \t]*(macro)[ \t]+([^ \t({[]+).*$/\2/m,macro/
    --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(function)[ \t]+([^ \t({[]+)[^(]*\([ \t]*([^ \t;,=)({]+).*$/\3 (\4, …)/f,function/
    --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(function)[ \t]+([^ \t({[]+)[^(]*(\([ \t]*\).*|\([ \t]*)$/\3/f,function/
    --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(([^@#$ \t({[]+)|\(([^@#$ \t({[]+)\)|\((\$)\))[ \t]*(\{.*\})?[ \t]*\([ \t]*\)[ \t]*=([^=].*$|$)/\3\4\5/f,function/
    --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(([^@#$ \t({[]+)|\(([^@#$ \t({[]+)\)|\((\$)\))[ \t]*(\{.*\})?[ \t]*\([ \t]*([^ \t;,=)({]+).*\)[ \t]*=([^=].*$|$)/\3\4\5 (\7, …)/f,function/
    --regex-Julia=/^[ \t]*(@defstruct)[ \t]+([^ \t({[]+).*$/\2/t,type/
    --regex-Julia=/^[ \t]*(@defimmutable)[ \t]+([^ \t({[]+).*$/\2/i,immutable/
  '';

  scheme = ''
    --langdef=Scheme
    --langmap=Scheme:.scm
    --regex-Scheme=/^[[:space:]]*(\(|[[])define[^[:space:]]*[[:space:]]+(\(|[[])?([^][[:space:]()]+)/\3/d,definition/i
  '';
}
