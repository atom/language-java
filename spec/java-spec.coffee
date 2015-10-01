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

    comment = ['source.java', 'meta.enum.java', 'comment.block.java']
    commentDefinition = comment.concat('punctuation.definition.comment.java')

    expect(lines[0][0]).toEqual value: 'enum', scopes: ['source.java', 'meta.enum.java', 'storage.modifier.java']
    expect(lines[0][2]).toEqual value: 'Letters', scopes: ['source.java', 'meta.enum.java', 'entity.name.type.enum.java']
    expect(lines[0][4]).toEqual value: '{', scopes: ['source.java', 'meta.enum.java', 'punctuation.section.enum.begin.java']
    expect(lines[1][1]).toEqual value: '/*', scopes: commentDefinition
    expect(lines[1][2]).toEqual value: '* Comment about A ', scopes: comment
    expect(lines[1][3]).toEqual value: '*/', scopes: commentDefinition
    expect(lines[2][1]).toEqual value: 'A', scopes: ['source.java', 'meta.enum.java', 'constant.other.enum.java']
    expect(lines[6][0]).toEqual value: '}', scopes: ['source.java', 'meta.enum.java', 'punctuation.section.enum.end.java']

  it 'tokenizes methods', ->
    lines = grammar.tokenizeLines '''
      class A
      {
        A(int a, int b)
        {
        }
      }
    '''

    expect(lines[2][1]).toEqual value: 'A', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'entity.name.function.java']
    expect(lines[2][2]).toEqual value: '(', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java']
    expect(lines[2][3]).toEqual value: 'int', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.primitive.array.java']
    expect(lines[2][5]).toEqual value: 'a', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'variable.parameter.java']
    expect(lines[2][6]).toEqual value: ', ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java']
    expect(lines[2][10]).toEqual value: ')', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java']
    expect(lines[3][1]).toEqual value: '{', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.begin.java']
    expect(lines[4][1]).toEqual value: '}', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.end.java']
