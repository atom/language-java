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

  it 'tokenizes arrow operator', ->
    {tokens} = grammar.tokenizeLine '(String s1) -> s1.length() - outer.length();'

    expect(tokens[1]).toEqual value: 'String', scopes: ['source.java', 'storage.type.java']
    expect(tokens[5]).toEqual value: '->', scopes: ['source.java', 'storage.type.function.arrow.java']
    expect(tokens[7]).toEqual value: '.', scopes: ['source.java', 'keyword.operator.dereference.java']
    expect(tokens[9]).toEqual value: '(', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.begin.java']
    expect(tokens[10]).toEqual value: ')', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.end.java']
    expect(tokens[12]).toEqual value: '-', scopes: ['source.java', 'keyword.operator.arithmetic.java']

  it 'tokenizes `new` statements', ->
    {tokens} = grammar.tokenizeLine 'int[] list = new int[10];'

    expect(tokens[8]).toEqual value: 'new', scopes: ['source.java', 'keyword.control.new.java']
    expect(tokens[9]).toEqual value: ' ', scopes: ['source.java']
    expect(tokens[10]).toEqual value: 'int', scopes: ['source.java', 'storage.type.primitive.array.java']
    expect(tokens[11]).toEqual value: '[', scopes: ['source.java', 'storage.type.primitive.array.java', 'meta.brace.square.java']
    expect(tokens[12]).toEqual value: '10', scopes: ['source.java', 'storage.type.primitive.array.java', 'constant.numeric.java']
    expect(tokens[13]).toEqual value: ']', scopes: ['source.java', 'storage.type.primitive.array.java', 'meta.brace.square.java']
    expect(tokens[14]).toEqual value: ';', scopes: ['source.java', 'puntuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'String[] list = new String[]{"hi", "abc", "etc"};'

    expect(tokens[8]).toEqual value: 'new', scopes: ['source.java', 'keyword.control.new.java']
    expect(tokens[10]).toEqual value: 'String', scopes: ['source.java', 'storage.type.object.array.java']
    expect(tokens[13]).toEqual value: '{', scopes: ['source.java', 'meta.brace.curly.java']
    expect(tokens[14]).toEqual value: '"', scopes: ['source.java', 'string.quoted.double.java', 'punctuation.definition.string.begin.java']
    expect(tokens[15]).toEqual value: 'hi', scopes: ['source.java', 'string.quoted.double.java']
    expect(tokens[16]).toEqual value: '"', scopes: ['source.java', 'string.quoted.double.java', 'punctuation.definition.string.end.java']
    expect(tokens[17]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter.java']
    expect(tokens[18]).toEqual value: ' ', scopes: ['source.java']
    expect(tokens[27]).toEqual value: '}', scopes: ['source.java', 'meta.brace.curly.java']
    expect(tokens[28]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'Point point = new Point(1, 4);'

    expect(tokens[8]).toEqual value: 'new', scopes: ['source.java', 'keyword.control.new.java']
    expect(tokens[10]).toEqual value: 'Point', scopes: ['source.java', 'meta.method-call.java', 'storage.type.java']
    expect(tokens[11]).toEqual value: '(', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.begin.java']
    expect(tokens[16]).toEqual value: ')', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.end.java']
    expect(tokens[17]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']

    lines = grammar.tokenizeLine '''
      Point point = new Point()
      {
        public void something(x)
        {
          int y = x;
        }
      };
      '''

    expect(lines[0][8]).toEqual value: 'new', scopes: ['source.java', 'keyword.control.new.java']
    expect(lines[0][10]).toEqual value: 'Point', scopes: ['source.java', 'meta.method-call.java', 'storage.type.java']
    expect(lines[1][0]).toEqual value: '{', scopes: ['source.java', 'meta.inner-class.java', 'punctuation.section.inner-class.begin.java']
    expect(lines[2][1]).toEqual value: 'public', scopes: ['source.java', 'meta.inner-class.java', 'meta.method.java', 'storage.modifier.java']
    expect(lines[4][1]).toEqual value: 'int', scopes: ['source.java', 'meta.inner-class.java', 'meta.method.java', 'meta.method.body.java', 'storage.type.primitive.array.java']
    expect(lines[6][0]).toEqual value: '}', scopes: ['source.java', 'meta.inner-class.java', 'punctuation.section.inner-class.end.java']
    expect(lines[6][1]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']
