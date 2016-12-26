import { moduleForModel, test } from 'ember-qunit';

moduleForModel('line-direction', 'Unit | Model | line direction', {
  // Specify the other units that are required for this test.
  needs: ['model:line']
});

test('it exists', function(assert) {
  let model = this.subject();
  // let store = this.store();
  assert.ok(!!model);
});
