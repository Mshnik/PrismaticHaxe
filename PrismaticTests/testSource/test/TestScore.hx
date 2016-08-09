package test;

import common.Color;
import common.ColorUtil;
import model.Score;
class TestScore extends TestCase {

  public function testConstruction() {
    var s = new Score();
    for(c in ColorUtil.realColors()) {
      assertEquals(0, s.getGoal(c));
    }
  }

  public function testGoalSetting() {
    var s = new Score();
    for(c in ColorUtil.realColors()) {
      assertEquals(s, s.setGoal(c, 2)); //Check return of this
      assertEquals(2, s.getGoal(c));
      assertEquals(0, s.getCount(c));
    }
    for(c in ColorUtil.realColors()) {
      assertEquals(2, s.get().get(c).getSecond());
    }

    s.setGoals([Color.RED, Color.BLUE], [1,3]);
    assertEquals(1, s.getGoal(Color.RED));
    assertEquals(2, s.getGoal(Color.YELLOW));
    assertEquals(3, s.getGoal(Color.BLUE));
  }

  public function testCountSetting() {
    var s = new Score();
    for(c in ColorUtil.realColors()) {
      assertEquals(s, s.setCount(c, 2)); //Check return of this
      assertEquals(2, s.getCount(c));
      assertEquals(0, s.getGoal(c));

      s.increment(c);
      assertEquals(3, s.getCount(c));
    }
    for(c in ColorUtil.realColors()) {
      assertEquals(3, s.get().get(c).getFirst());
    }

    s.setCounts([Color.RED, Color.BLUE], [2,4]);
    assertEquals(2, s.getCount(Color.RED));
    assertEquals(3, s.getCount(Color.YELLOW));
    assertEquals(4, s.getCount(Color.BLUE));
  }

  public function testIsSatisfied() {
    var s = new Score();
    assertTrue(s.isSatisfied());

    s.setGoal(Color.RED, 1);
    assertFalse(s.isSatisfied());

    s.increment(Color.RED);
    assertTrue(s.isSatisfied());

    s.setGoal(Color.BLUE, 2);
    assertFalse(s.isSatisfied());

    s.increment(Color.BLUE);
    assertFalse(s.isSatisfied());

    s.increment(Color.RED);
    assertFalse(s.isSatisfied());

    s.increment(Color.BLUE);
    assertTrue(s.isSatisfied());

    s.increment(Color.RED);
    assertTrue(s.isSatisfied());
  }

  public function testEquals() {
    var s = new Score();
    var s2 = new Score();

    assertEquitable(s, s);
    assertNotEquitable(s, null);

    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.setGoal(Color.RED, 1);

    assertNotEquitable(s, s2);
    assertNotEquitable(s2, s);

    s2.setGoal(Color.RED, 1);

    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.increment(Color.RED);

    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.setGoal(Color.RED, 2);
    s2.setGoal(Color.RED, 2);

    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.increment(Color.RED);

    assertEquitable(s, s2);
    assertEquitable(s2, s);

    s.setGoal(Color.BLUE, 2);

    assertNotEquitable(s, s2);
    assertNotEquitable(s2, s);
  }
}
