import 'dart:math' as math;

class CalculatorEngine {


  // Parse and evaluate mathematical expressions
  static double evaluate(String expression) {
    try {
      // Convert display operators to calculation operators
      expression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '**');

      // Simple evaluation for basic operations
      return _evaluateExpression(expression);
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  static double _evaluateExpression(String expr) {
    // This is a simplified evaluator - in production, you'd use a proper parser
    expr = expr.replaceAll(' ', '');

    // Handle parentheses first
    while (expr.contains('(')) {
      int start = expr.lastIndexOf('(');
      int end = expr.indexOf(')', start);
      String subExpr = expr.substring(start + 1, end);
      double result = _evaluateSimple(subExpr);
      expr = expr.substring(0, start) + result.toString() + expr.substring(end + 1);
    }

    return _evaluateSimple(expr);
  }

  static double _evaluateSimple(String expr) {
    // Handle power operations first
    while (expr.contains('**')) {
      RegExp powerRegex = RegExp(r'(-?\d+(?:\.\d+)?)\*\*(-?\d+(?:\.\d+)?)');
      Match? match = powerRegex.firstMatch(expr);
      if (match != null) {
        double base = double.parse(match.group(1)!);
        double exponent = double.parse(match.group(2)!);
        double result = math.pow(base, exponent).toDouble();
        expr = expr.replaceFirst(match.group(0)!, result.toString());
      } else {
        break;
      }
    }

    // Handle multiplication and division
    while (expr.contains('*') || expr.contains('/')) {
      RegExp mulDivRegex = RegExp(r'(-?\d+(?:\.\d+)?)([*/])(-?\d+(?:\.\d+)?)');
      Match? match = mulDivRegex.firstMatch(expr);
      if (match != null) {
        double left = double.parse(match.group(1)!);
        String operator = match.group(2)!;
        double right = double.parse(match.group(3)!);
        double result = operator == '*' ? left * right : left / right;
        expr = expr.replaceFirst(match.group(0)!, result.toString());
      } else {
        break;
      }
    }

    // Handle addition and subtraction
    while (expr.contains('+') || (expr.contains('-') && expr.lastIndexOf('-') > 0)) {
      RegExp addSubRegex = RegExp(r'(-?\d+(?:\.\d+)?)([+-])(\d+(?:\.\d+)?)');
      Match? match = addSubRegex.firstMatch(expr);
      if (match != null) {
        double left = double.parse(match.group(1)!);
        String operator = match.group(2)!;
        double right = double.parse(match.group(3)!);
        double result = operator == '+' ? left + right : left - right;
        expr = expr.replaceFirst(match.group(0)!, result.toString());
      } else {
        break;
      }
    }

    return double.parse(expr);
  }

  // Scientific functions
  static double sin(double value) => math.sin(value * math.pi / 180);
  static double cos(double value) => math.cos(value * math.pi / 180);
  static double tan(double value) => math.tan(value * math.pi / 180);
  static double log(double value) => math.log(value);
  static double sqrt(double value) => math.sqrt(value);
  static double factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }
}
