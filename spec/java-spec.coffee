describe 'Java grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-java')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.java')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.java'

  it 'tokenizes this with `.this` class', ->
    {tokens} = grammar.tokenizeLine 'this.x'

    expect(tokens[0]).toEqual value: 'this', scopes: ['source.java', 'variable.language.this.java']

  it 'tokenizes classes', ->
    lines = grammar.tokenizeLines '''
      class Thing {
        int x;
      }
    '''

    expect(lines[0][0]).toEqual value: 'class', scopes: ['source.java', 'meta.class.java', 'meta.class.identifier.java', 'storage.modifier.java']
    expect(lines[0][2]).toEqual value: 'Thing', scopes: ['source.java', 'meta.class.java', 'meta.class.identifier.java', 'entity.name.type.class.java']

  it 'tokenizes enums', ->
    lines = grammar.tokenizeLines '''
      enum Letters {
        /** Comment about A */
        A,

        // Comment about B
        B
      }
    '''

    comment = ['source.java', 'meta.class.java', 'meta.class.body.java', 'comment.block.java']
    commentDefinition = comment.concat('punctuation.definition.comment.java')

    expect(lines[1][1]).toEqual value: '/*', scopes: commentDefinition
    expect(lines[1][2]).toEqual value: '* Comment about A ', scopes: comment
    expect(lines[1][3]).toEqual value: '*/', scopes: commentDefinition
    expect(lines[2][1]).toEqual value: 'A', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.enum.java', 'constant.other.enum.java']
