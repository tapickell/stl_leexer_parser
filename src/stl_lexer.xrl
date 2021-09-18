Definitions.

IDENTIFIER = .+
SIGN = (\+|-)
DIGIT = [0-9]
INTEGER = {SIGN}?{DIGIT}+
FLOAT = {SIGN}?{INTEGER}\.{INTEGER}((E|e)(\+|-)?{INTEGER})?
NUMBER = ({FLOAT}|{INTEGER})
SPACE = \s+
KW_SOLID = solid
KW_NORMAL = normal
KW_FACET = facet
KW_OUTER = outer
KW_LOOP = loop
KW_VERTEX = vertex
KW_END = end
NEW_LINE  = [\n]
START_SOLID = {KW_SOLID}{SPACE}{IDENTIFIER}
POINT = {NUMBER}{SPACE}{NUMBER}{SPACE}{NUMBER}
START_FACET = {KW_FACET}{SPACE}{KW_NORMAL}{SPACE}{POINT}
START_LOOP = {KW_OUTER}{SPACE}{KW_LOOP}
END_SOLID = {KW_END}{START_SOLID}
END_FACET = {KW_END}{KW_FACET}
END_LOOP = {KW_END}{KW_LOOP}
VERTEX_POINT = {KW_VERTEX}{SPACE}{POINT}

Rules.

{START_SOLID} : {token, {start_solid, TokenLine, TokenChars}}.
{START_FACET} : {token, {start_facet, TokenLine, TokenChars}}.
{START_LOOP} : {token, {start_loop, TokenLine, TokenChars}}.
{END_SOLID}   : {end_token, {end_solid, TokenLine, TokenChars}}.
{END_FACET}   : {token, {end_facet, TokenLine, TokenChars}}.
{END_LOOP}   : {token, {end_loop, TokenLine, TokenChars}}.
{VERTEX_POINT}   : {token, {vertex, TokenLine, TokenChars}}.
{SPACE} : skip_token.
% {IDENTIFIER} : {token, {identifier, TokenLine, TokenChars}}.
{NEW_LINE}  : skip_token.

Erlang code.
