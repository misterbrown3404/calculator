import 'package:calculator/service/calculatorEngine.dart';
import 'package:calculator/model/calculatorHistory.dart';
import 'package:calculator/model/memoryManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State <CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  // State variables
  String _display = '0';
  String _expression = '';
  bool _isNewCalculation = true;
  bool _showingResult = false;

  // Advanced features
  final MemoryManager _memory = MemoryManager();
  final List<CalculationHistory> _history = [];
  bool _isScientificMode = false;
  bool _showHistory = false;

  // Animation controllers
  late AnimationController _buttonAnimationController;
  late AnimationController _displayAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _displayAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _displayAnimationController.dispose();
    super.dispose();
  }

  // Button press animation
  void _animateButton() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
  }

  // Display update animation
  void _animateDisplay() {
    _displayAnimationController.forward().then((_) {
      _displayAnimationController.reverse();
    });
  }

  // Input handling methods
  void _handleNumberInput(String number) {
    setState(() {
      HapticFeedback.lightImpact();
      _animateButton();

      if (_isNewCalculation || _display == '0') {
        _display = number;
        _isNewCalculation = false;
      } else {
        _display += number;
      }
      _showingResult = false;
    });
  }

  void _handleOperatorInput(String operator) {
    setState(() {
      HapticFeedback.mediumImpact();
      _animateButton();

      if (_expression.isNotEmpty && !_showingResult) {
        _calculateResult();
      }

      _expression = '$_display $operator ';
      _isNewCalculation = true;
      _showingResult = false;
    });
  }

  void _calculateResult() {
    try {
      String fullExpression = _expression + _display;
      double result = CalculatorEngine.evaluate(fullExpression);

      // Add to history
      _history.insert(0, CalculationHistory(
        expression: fullExpression,
        result: _formatResult(result),
        timestamp: DateTime.now(),
      ));

      setState(() {
        _display = _formatResult(result);
        _expression = '';
        _isNewCalculation = true;
        _showingResult = true;
      });

      _animateDisplay();
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() {
        _display = 'Error';
        _expression = '';
        _isNewCalculation = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _handleSpecialFunction(String function) {
    setState(() {
      HapticFeedback.mediumImpact();
      double currentValue = double.tryParse(_display) ?? 0.0;
      double result = 0.0;

      switch (function) {
        case 'log':
          result = CalculatorEngine.log(currentValue);
          break;
        case 'sqrt':
          result = CalculatorEngine.sqrt(currentValue);
          break;
        case 'square':
          result = currentValue * currentValue;
          break;
        case 'factorial':
          if (currentValue >= 0 && currentValue == currentValue.toInt()) {
            result = CalculatorEngine.factorial(currentValue.toInt());
          } else {
            _display = 'Error';
            return;
          }
          break;
        case 'reciprocal':
          result = 1 / currentValue;
          break;
      }

      _display = _formatResult(result);
      _isNewCalculation = true;
    });
  }

  void _handleMemoryOperation(String operation) {
    setState(() {
      HapticFeedback.mediumImpact();
      double currentValue = double.tryParse(_display) ?? 0.0;

      switch (operation) {
        case 'MC':
          _memory.clear();
          break;
        case 'MR':
          _display = _formatResult(_memory.value);
          _isNewCalculation = true;
          break;
        case 'MS':
          _memory.store(currentValue);
          break;
        case 'M+':
          _memory.add(currentValue);
          break;
        case 'M-':
          _memory.subtract(currentValue);
          break;
      }
    });
  }

  void _clear() {
    setState(() {
      HapticFeedback.heavyImpact();
      _display = '0';
      _expression = '';
      _isNewCalculation = true;
      _showingResult = false;
    });
  }

  void _backspace() {
    setState(() {
      HapticFeedback.lightImpact();
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _toggleScientificMode() {
    setState(() {
      _isScientificMode = !_isScientificMode;
    });
  }

  void _toggleHistory() {
    setState(() {
      _showHistory = !_showHistory;
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Advanced Calculator'),
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isScientificMode ? Icons.functions : Icons.calculate),
            onPressed: _toggleScientificMode,
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _toggleHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expression display
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  SizedBox(height: 10),
                  // Main display
                  AnimatedBuilder(
                    animation: _displayAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_displayAnimationController.value * 0.05),
                        child: Text(
                          _display,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                  // Memory indicator
                  if (_memory.hasValue)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.memory, color: Colors.blue, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'M: ${_formatResult(_memory.value)}',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // History Panel
          if (_showHistory)
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.clear_all),
                            onPressed: _clearHistory,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return ListTile(
                            title: Text(item.expression),
                            subtitle: Text(
                              '= ${item.result}',
                              style: TextStyle(color: Colors.blue),
                            ),
                            trailing: Text(
                              '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            onTap: () {
                              setState(() {
                                _display = item.result;
                                _isNewCalculation = true;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Button Panel
          Expanded(
            flex: _isScientificMode ? 4 : 3,
            child: Container(
              padding: EdgeInsets.all(10),
              child: _isScientificMode ? _buildScientificKeypad() : _buildBasicKeypad(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicKeypad() {
    return Column(
      children: [
        // Memory and Clear row
        Expanded(
          child: Row(
            children: [
              _buildButton('MC', _memory.hasValue ? Colors.blue : Colors.grey[700]!, () => _handleMemoryOperation('MC')),
              _buildButton('MR', _memory.hasValue ? Colors.blue : Colors.grey[700]!, () => _handleMemoryOperation('MR')),
              _buildButton('MS', Colors.blue, () => _handleMemoryOperation('MS')),
              _buildButton('M+', Colors.blue, () => _handleMemoryOperation('M+')),
              _buildButton('M-', Colors.blue, () => _handleMemoryOperation('M-')),
            ],
          ),
        ),
        // First row
        Expanded(
          child: Row(
            children: [
              _buildButton('C', Colors.red, _clear),
              _buildButton('⌫', Colors.orange, _backspace),
              _buildButton('÷', Colors.orange, () => _handleOperatorInput('÷')),
            ],
          ),
        ),
        // Second row
        Expanded(
          child: Row(
            children: [
              _buildButton('7', Colors.grey[800]!, () => _handleNumberInput('7')),
              _buildButton('8', Colors.grey[800]!, () => _handleNumberInput('8')),
              _buildButton('9', Colors.grey[800]!, () => _handleNumberInput('9')),
              _buildButton('×', Colors.orange, () => _handleOperatorInput('×')),
            ],
          ),
        ),
        // Third row
        Expanded(
          child: Row(
            children: [
              _buildButton('4', Colors.grey[800]!, () => _handleNumberInput('4')),
              _buildButton('5', Colors.grey[800]!, () => _handleNumberInput('5')),
              _buildButton('6', Colors.grey[800]!, () => _handleNumberInput('6')),
              _buildButton('-', Colors.orange, () => _handleOperatorInput('-')),
            ],
          ),
        ),
        // Fourth row
        Expanded(
          child: Row(
            children: [
              _buildButton('1', Colors.grey[800]!, () => _handleNumberInput('1')),
              _buildButton('2', Colors.grey[800]!, () => _handleNumberInput('2')),
              _buildButton('3', Colors.grey[800]!, () => _handleNumberInput('3')),
              _buildButton('+', Colors.orange, () => _handleOperatorInput('+')),
            ],
          ),
        ),
        // Fifth row
        Expanded(
          child: Row(
            children: [
              _buildButton('0', Colors.grey[800]!, () => _handleNumberInput('0'), flex: 2),
              _buildButton('.', Colors.grey[800]!, () => _handleNumberInput('.')),
              _buildButton('=', Colors.blue, _calculateResult),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificKeypad() {
    return Column(
      children: [
        // Memory row
        Expanded(
          child: Row(
            children: [
              _buildButton('MC', _memory.hasValue ? Colors.blue : Colors.grey[700]!, () => _handleMemoryOperation('MC')),
              _buildButton('MR', _memory.hasValue ? Colors.blue : Colors.grey[700]!, () => _handleMemoryOperation('MR')),
              _buildButton('MS', Colors.blue, () => _handleMemoryOperation('MS')),
              _buildButton('M+', Colors.blue, () => _handleMemoryOperation('M+')),
              _buildButton('M-', Colors.blue, () => _handleMemoryOperation('M-')),
            ],
          ),
        ),
        // Scientific functions row 1
        Expanded(
          child: Row(
            children: [
              _buildButton('log', Colors.purple, () => _handleSpecialFunction('log')),
              _buildButton('√', Colors.purple, () => _handleSpecialFunction('sqrt')),
            ],
          ),
        ),
        // Scientific functions row 2
        Expanded(
          child: Row(
            children: [
              _buildButton('x²', Colors.purple, () => _handleSpecialFunction('square')),
              _buildButton('x!', Colors.purple, () => _handleSpecialFunction('factorial')),
            ],
          ),
        ),
        // Clear and operators row
        Expanded(
          child: Row(
            children: [
              _buildButton('C', Colors.red, _clear),
              _buildButton('⌫', Colors.orange, _backspace),
              _buildButton('^', Colors.orange, () => _handleOperatorInput('^')),
              _buildButton('÷', Colors.orange, () => _handleOperatorInput('÷')),
            ],
          ),
        ),
        // Number rows
        Expanded(
          child: Row(
            children: [
              _buildButton('7', Colors.grey[800]!, () => _handleNumberInput('7')),
              _buildButton('8', Colors.grey[800]!, () => _handleNumberInput('8')),
              _buildButton('9', Colors.grey[800]!, () => _handleNumberInput('9')),
              _buildButton('×', Colors.orange, () => _handleOperatorInput('×')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('4', Colors.grey[800]!, () => _handleNumberInput('4')),
              _buildButton('5', Colors.grey[800]!, () => _handleNumberInput('5')),
              _buildButton('6', Colors.grey[800]!, () => _handleNumberInput('6')),
              _buildButton('-', Colors.orange, () => _handleOperatorInput('-')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('1', Colors.grey[800]!, () => _handleNumberInput('1')),
              _buildButton('2', Colors.grey[800]!, () => _handleNumberInput('2')),
              _buildButton('3', Colors.grey[800]!, () => _handleNumberInput('3')),
              _buildButton('+', Colors.orange, () => _handleOperatorInput('+')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('0', Colors.grey[800]!, () => _handleNumberInput('0'), flex: 2),
              _buildButton('.', Colors.grey[800]!, () => _handleNumberInput('.')),
              _buildButton('=', Colors.blue, _calculateResult),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.all(2),
        child: AnimatedBuilder(
          animation: _buttonAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_buttonAnimationController.value * 0.1),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
