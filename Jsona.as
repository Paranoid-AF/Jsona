#include "JsonaValue"
#include "JsonaTokenizer"

namespace Jsona {
  int pos = 0;
  array < Token @ > tokens;
  Tokenizer tokenizer;

  Value @ parse(string str) {
    pos = 0;
    tokens.resize(0);

    tokens = tokenizer.parse(str);
    Value @ head = process();
    return head;
  }

  Value@ process() {
    if (tokens.length() < 1) {
      g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] No token found in the target string!\n");
      return Value();
    } 

    switch (tokens[pos].getType()) {
      case BEGIN_OBJECT: return processObject();
      case BEGIN_ARRAY: return processArray();
      case NULL: return processNull();
      case NUMBER: return processNumber();
      case STRING: return processString();
      case BOOLEAN: return processBoolean();
    }

    return Value();
  }

  bool isElement(TokenType type) {
    return (type == BEGIN_OBJECT || type == BEGIN_ARRAY || type == NULL || type == NUMBER || type == STRING || type == BOOLEAN);
  }

  Value @ processBoolean() {
    string val = tokens[pos].getValue();
    bool targetValue = atobool(val);
    return Value(targetValue);
  }

  Value @ processNumber() {
    string val = tokens[pos].getValue();
    if (val.Find(".") == String::INVALID_INDEX) { // Check int or real
      // int
      int targetValue = atoi(val);
      return Value(targetValue);
    } else {
      // real
      double targetValue = atod(val);
      return Value(targetValue);
    }
  }

  Value @ processNull() {
    return Value();
  }

  Value @ processString() {
    string val = tokens[pos].getValue();
    return Value(val);
  }

  Value @ processObject() {
    dictionary result;
    while (pos < int(tokens.length()) && tokens[pos].getType() != END_OBJECT) {
      if (tokens[pos].getType() == SEP_COLON) {

        if (pos - 1 >= 0 && pos + 1 < int(tokens.length()) && tokens[pos - 1].getType() == STRING && isElement(tokens[pos + 1].getType())) { // has key
          pos++;
          string key = tokens[pos - 2].getValue();
          result.set(key, process());
        } else {
          g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] Invalid key-value in an object.\n");
        }
      }
      pos++;
    }
    return Value(result);
  }

  Value @ processArray() {
    array < Value @ > result;
    pos++;
    while (pos < int(tokens.length()) && tokens[pos].getType() != END_ARRAY) {
      if (tokens[pos].getType() == SEP_COMMA) {
        pos++;
        continue;
      }
      if (isElement(tokens[pos].getType())) {
        result.insertLast(process());
      } else {
        g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] Invalid value in an array.\n");
      }

      pos++;
    }
    return Value(result);
  }

  string stringify(Value @ head) {
    string result = "";

    switch (head.type()) {
      case OBJECT_VALUE: {
        result += "{";
        dictionary val = dictionary(head);
        array < string > keys = val.getKeys();
        for (uint i = 0; i < keys.length(); i++) {
          result += "\"" + keys[i] + "\"";
          result += ":";
          Value @ temp = cast < Value @ > (val[keys[i]]);
          result += stringify(temp);
          if (i != keys.length() - 1) {
            result += ",";
          }
        }
        result += "}";
        break;
      }
      case ARRAY_VALUE: {
          result += "[";
          array < Value @ > val = array < Value @ > (head);
          for (uint i = 0; i < val.length(); i++) {
            result += stringify(val[i]);
            if (i != val.length() - 1) {
              result += ",";
            }
          }
          result += "]";
          break;
      }
      case BOOLEAN_VALUE: {
        result += bool(head) ? "true" : "false";
        break;
      }
      case STRING_VALUE: {
        result += "\"" + string(head) + "\"";
        break;
      }
      case INT_VALUE: {
        result += string(int(head));
        break;
      }
      case REAL_VALUE: {
        result += string(double(head));
        break;
      }
      case NULL_VALUE: {
        result += "null";
        break;
      }
    }
    
    return result;
  }
}