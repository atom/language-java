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

  fit 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.java'

  fit 'tokenizes imports', ->
    tokens = tokenizeLine 'import com.package;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[4]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  fit 'tokenizes static imports', ->
    tokens = tokenizeLine 'import static com.package;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
    expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  fit 'tokenizes imports with asterisk', ->
    tokens = tokenizeLine 'import static com.package.*;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
    expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
    expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[7]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
    expect(tokens[8]).toEqual value: '*', scopes: ['source.java', 'meta.import', 'support.storage.type']
    expect(tokens[9]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']

  fit 'tokenizes imports 2', ->
    tokens = tokenizeLines '''
      import com.test.package1;
      import com.test.package2;
      import static com.test.package3.CONSTANT;
    '''
    console.log(tokens[0], tokens[1], tokens[2])
