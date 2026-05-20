package build.aspect.java;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Tests for Calculator. */
@RunWith(JUnit4.class)
public final class CalculatorTest {

    private Calculator calculator;

    @Before
    public void setUp() {
        calculator = new Calculator();
    }

    @Test
    public void testAdd() {
        assertEquals(4, calculator.add(2, 2));
        assertEquals(0, calculator.add(-1, 1));
        assertEquals(-3, calculator.add(-1, -2));
    }

    @Test
    public void testSubtract() {
        assertEquals(1, calculator.subtract(3, 2));
        assertEquals(-2, calculator.subtract(0, 2));
    }

    @Test
    public void testMultiply() {
        assertEquals(6, calculator.multiply(2, 3));
        assertEquals(0, calculator.multiply(5, 0));
        assertEquals(-8, calculator.multiply(-2, 4));
    }

    @Test
    public void testDivide() {
        assertEquals(2.0, calculator.divide(6, 3), 0.001);
        assertEquals(0.5, calculator.divide(1, 2), 0.001);
    }

    @Test
    public void testAddWithZero() {
        assertEquals(5, calculator.add(5, 0));
        assertEquals(0, calculator.add(0, 0));
    }

      @Test
      public void testDivideByZero() {
          assertThrows(IllegalArgumentException.class, () -> calculator.divide(1, 0));
      }
}
