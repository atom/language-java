{TextEditor} = require 'atom'

describe 'Tree-sitter based Java grammar', ->
  grammar = null
  editor = null
  buffer = null

  beforeEach ->
    atom.config.set('core.useTreeSitterParsers', true)

    waitsForPromise ->
      atom.packages.activatePackage('language-java')

    runs ->
      editor = new TextEditor()
      grammar = atom.grammars.grammarForScopeName('source.java')
      editor.setGrammar(grammar)
      buffer = editor.getBuffer()

  # Compatibility functions with TextMate grammar tests

  # Returns list of tokens as [{value: ..., scopes: [...]}, ...]
  getTokens = (buffer, row) ->
    line = buffer.lineForRow row
    tokens = []

    iterator = buffer.getLanguageMode().buildHighlightIterator()
    start = {row: row, column: 0}
    scopes = iterator.seek(start, row)

    while true
      end = iterator.getPosition()

      if end.row > row
        end.row = row
        end.column = line.length

      if end.column > start.column
        tokens.push({
          value: line.substring(start.column, end.column),
          scopes: buffer.getLanguageMode().grammar.scopeNameForScopeId(s) for s in scopes
        })

      if end.column < line.length
        for num in iterator.getCloseScopeIds()
          item = scopes.pop()
        scopes.push(iterator.getOpenScopeIds()...)
        start = end
        iterator.moveToSuccessor()
      else
        break

    tokens

  tokenizeLine = (text) ->
    buffer.setText(text)
    getTokens(buffer, 0)

  tokenizeLines = (text) ->
    buffer.setText(text)
    lines = buffer.getLines()
    tokens = []
    row = 0
    for _ in lines
      tokens.push(getTokens(buffer, row))
      row += 1
    tokens

  # Unit tests

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.java'

  it 'tokenizes brackets', ->
    tokens = tokenizeLine '{ (a + b) + c[d] }'

    expect(tokens[0]).toEqual value: '{', scopes: ['source.java', 'punctuation.bracket.curly']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.java', 'punctuation.bracket.round']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.java', 'punctuation.bracket.round']
    expect(tokens[10]).toEqual value: '[', scopes: ['source.java', 'punctuation.bracket.square']
    expect(tokens[12]).toEqual value: ']', scopes: ['source.java', 'punctuation.bracket.square']
    expect(tokens[14]).toEqual value: '}', scopes: ['source.java', 'punctuation.bracket.curly']

  it 'tokenizes punctuation', ->
    tokens = tokenizeLine 'int a, b, c;'

    expect(tokens[2]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter']
    expect(tokens[6]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

    tokens = tokenizeLine 'a.b.c();'

    expect(tokens[1]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

    tokens = tokenizeLine 'new com.package.Clazz();'

    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[9]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

  fit 'tokenizes instanceof', ->
    tokens = tokenizeLine 'a instanceof A'

    expect(tokens[1]).toEqual value: 'instanceof', scopes: ['source.java', 'keyword.operator.instanceof']

  fit 'tokenizes comparison', ->
    tokens = tokenizeLines '''
      a > b;
      a < b;
      a == b;
      a >= b;
      a <= b;
      a != b;
    '''

    expect(tokens[0][1]).toEqual value: '>', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[1][1]).toEqual value: '<', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[2][1]).toEqual value: '==', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[3][1]).toEqual value: '>=', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[4][1]).toEqual value: '<=', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[5][1]).toEqual value: '!=', scopes: ['source.java', 'keyword.operator.comparison']

  fit 'tokenizes logical', ->
    tokens = tokenizeLines '''
      a && b;
      a || b;
      !a;
    '''

    expect(tokens[0][1]).toEqual value: '&&', scopes: ['source.java', 'keyword.operator.logical']
    expect(tokens[1][1]).toEqual value: '||', scopes: ['source.java', 'keyword.operator.logical']
    expect(tokens[2][0]).toEqual value: '!', scopes: ['source.java', 'keyword.operator.logical']

  fit 'tokenizes arithmetic', ->
    tokens = tokenizeLines '''
      a + b;
      a - b;
      a * b;
      a / b;
      a % b;
      a += b;
      a -= b;
      a *= b;
      a /= b;
      a %= b;
      a++;
      --a;
    '''

    expect(tokens[0][1]).toEqual value: '+', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[1][1]).toEqual value: '-', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[2][1]).toEqual value: '*', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[3][1]).toEqual value: '/', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[4][1]).toEqual value: '%', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[5][1]).toEqual value: '+=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[6][1]).toEqual value: '-=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[7][1]).toEqual value: '*=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[8][1]).toEqual value: '/=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[9][1]).toEqual value: '%=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[10][1]).toEqual value: '++', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[11][0]).toEqual value: '--', scopes: ['source.java', 'keyword.operator.arithmetic']

  fit 'tokenizes bitwise', ->
    tokens = tokenizeLines '''
      a & b;
      a | b;
      a ^ b;
      a >> b;
      a << b;
      a >>> b;
      a &= b;
      a |= b;
      a ^= b;
      a >>= b;
      a <<= b;
      a >>>= b;
      ~a;
    '''

    expect(tokens[0][1]).toEqual value: '&', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[1][1]).toEqual value: '|', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[2][1]).toEqual value: '^', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[3][1]).toEqual value: '>>', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[4][1]).toEqual value: '<<', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[5][1]).toEqual value: '>>>', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[6][1]).toEqual value: '&=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[7][1]).toEqual value: '|=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[8][1]).toEqual value: '^=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[9][1]).toEqual value: '>>=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[10][1]).toEqual value: '<<=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[11][1]).toEqual value: '>>>=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[12][0]).toEqual value: '~', scopes: ['source.java', 'keyword.operator.bitwise']

  fit 'tokenizes literals', ->
    tokens = tokenizeLines '''
      a = null;
      a = true;
      a = false;
      a = 123;
      a = 123L;
      a = 123.0d;
      a = 'a';
      a = "abc";
    '''

    expect(tokens[0][3]).toEqual value: 'null', scopes: ['source.java', 'constant.language.null']
    expect(tokens[1][3]).toEqual value: 'true', scopes: ['source.java', 'constant.boolean']
    expect(tokens[2][3]).toEqual value: 'false', scopes: ['source.java', 'constant.boolean']
    expect(tokens[3][3]).toEqual value: '123', scopes: ['source.java', 'constant.numeric']
    expect(tokens[4][3]).toEqual value: '123L', scopes: ['source.java', 'constant.numeric']
    expect(tokens[5][3]).toEqual value: '123.0d', scopes: ['source.java', 'constant.numeric']
    expect(tokens[6][3]).toEqual value: '\'a\'', scopes: ['source.java', 'string.quoted.single']
    expect(tokens[7][3]).toEqual value: '\"abc\"', scopes: ['source.java', 'string.quoted.double']

  it 'tokenizes imports', ->
    tokens = tokenizeLine 'import com.package;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[4]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  it 'tokenizes static imports', ->
    tokens = tokenizeLine 'import static com.package;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
    expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  it 'tokenizes imports with asterisk', ->
    tokens = tokenizeLine 'import static com.package.*;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
    expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[7]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[8]).toEqual value: '*', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[9]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  fit 'tokenizes classes', ->
    tokens = tokenizeLine 'public abstract class A { }'

    expect(tokens[0]).toEqual value: 'public', scopes: ['source.java', 'storage.modifier']
    expect(tokens[2]).toEqual value: 'abstract', scopes: ['source.java', 'storage.modifier']
    expect(tokens[4]).toEqual value: 'class', scopes: ['source.java', 'keyword.other.class']
    expect(tokens[6]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.class']
    expect(tokens[8]).toEqual value: '{', scopes: ['source.java', 'meta.class.body', 'punctuation.bracket.curly']
    expect(tokens[10]).toEqual value: '}', scopes: ['source.java', 'meta.class.body', 'punctuation.bracket.curly']

    tokens = tokenizeLine 'class A extends B implements C, D { }'

    expect(tokens[0]).toEqual value: 'class', scopes: ['source.java', 'keyword.other.class']
    expect(tokens[2]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.class']
    expect(tokens[4]).toEqual value: 'extends', scopes: ['source.java', 'storage.modifier']
    expect(tokens[6]).toEqual value: 'B', scopes: ['source.java', 'support.storage.type']
    expect(tokens[8]).toEqual value: 'implements', scopes: ['source.java', 'storage.modifier']
    expect(tokens[10]).toEqual value: 'C', scopes: ['source.java', 'support.storage.type']
    expect(tokens[13]).toEqual value: 'D', scopes: ['source.java', 'support.storage.type']
