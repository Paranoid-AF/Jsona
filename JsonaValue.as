namespace Jsona {
  enum ValueType {
    OBJECT_VALUE,
    ARRAY_VALUE,
    BOOLEAN_VALUE,
    STRING_VALUE,
    INT_VALUE,
    REAL_VALUE,
    NULL_VALUE
  }

  // Value 里面存储的数组和对象的元素类型都是 Value

  // 你问为什么？当然是因为静态类型语言不便存储可变类型的变量，同时不整个类不便于得知当前存储的是哪种变量

  class Value {
    private ValueType contentType = NULL_VALUE;
    private int valueInt = 0;
    private string valueString = "";
    private bool valueBoolean = false;
    private double valueReal = 0;
    private array < Value @ > @ valueArray = null;
    private dictionary @ valueObject = null;
    Value() {
      set();
    }

    Value(bool value) {
      set(value);
    }

    Value(string value) {
      set(value);
    }

    Value(int value) {
      set(value);
    }

    Value(double value) {
      set(value);
    }

    Value(array < Value @ > value) {
      set(value);
    }

    Value(dictionary value) {
      set(value);
    }

    private void dangerouslyResetValue() {
      valueInt = 0;
      valueString = "";
      valueBoolean = false;
      valueReal = 0;
      @valueArray = null;
      @valueObject = null;
    }

    ValueType type() {
      return this.contentType;
    }

    bool opConv() {
      return this.valueBoolean;
    }
    string opConv() {
      return this.valueString;
    }
    int opConv() {
      return this.valueInt;
    }
    double opConv() {
      return this.valueReal;
    }
    array < Value @ > @ opConv() {
      return @this.valueArray;
    }
    dictionary @ opConv() {
      return @this.valueObject;
    }

    void set() {
      dangerouslyResetValue();
      this.contentType = NULL_VALUE;
    }

    void set(bool value) {
      dangerouslyResetValue();
      this.contentType = BOOLEAN_VALUE;
      this.valueBoolean = value;
    }

    void set(string value) {
      dangerouslyResetValue();
      this.contentType = STRING_VALUE;
      this.valueString = value;
    }

    void set(int value) {
      dangerouslyResetValue();
      this.contentType = INT_VALUE;
      this.valueInt = value;
    }

    void set(double value) {
      dangerouslyResetValue();
      this.contentType = REAL_VALUE;
      this.valueReal = value;
    }

    void set(array < Value @ > value) {
      dangerouslyResetValue();
      this.contentType = ARRAY_VALUE;
      @this.valueArray = @value; // 注意: 这里使用引用以避免重复深拷贝，同时还可以使数据双向流动
    }

    void set(dictionary value) {
      dangerouslyResetValue();
      this.contentType = OBJECT_VALUE;
      @this.valueObject = @value; // 注意: 这里使用引用以避免重复深拷贝，同时还可以使数据双向流动
    }


    private bool isNumber(string str) {
      bool val = true;
      for (uint i = 0; i < str.Length(); i++) {
        if (!isdigit(str.SubString(i, 1))) {
          val = false;
          break;
        }
      }
      return val;
    }

    /*
      好耶，是语法糖！
      为了便于嵌套访问数据（比如 arr[0]["key"][0]["key1"]），JsonaValue 会为程序代为访问 array 和 dictionary，并返回相应的 JsonaValue。
    */


    // 代为访问 array
    private Value @ get_helper_arr(int idx) {
      if (idx >= int(valueArray.length()) || idx < 0) {
        g_Game.AlertMessage(at_console, "[ERROR::Value] Cannot access the array value for out of bound.\n");
        return null;
      } else {
        return valueArray[idx];
      }
    }

    private void set_helper_arr(int idx, Value @ value) {
      if (idx >= int(valueArray.length()) || idx < 0) {
        g_Game.AlertMessage(at_console, "[ERROR::Value] Cannot modify the array value for out of bound.\n");
      } else {
        valueArray[idx] = value;
      }
    }

    Value @ get_opIndex(string idx) {
      if (this.contentType != OBJECT_VALUE) {
        if (this.contentType == ARRAY_VALUE) {
          if (isNumber(idx)) {
            int idx_num = atoi(idx);
            return get_helper_arr(idx_num);
          } else {
            g_Game.AlertMessage(at_console, "[ERROR::Value] Cannot access an array value with a non-integer key.\n");
          }
        } else {
          g_Game.AlertMessage(at_console, "[ERROR::Value] Operator overloads must work with an array or a dictionary.\n");
        }
        return null;
      }

      if (!valueObject.exists(idx)) {
        valueObject[idx] = Value(dictionary = {});
      }

      return cast < Value @ > (valueObject[idx]);
    }

    // 代为写入 dictionary
    void set_opIndex(string idx, Value @ value) {
      if (this.contentType != OBJECT_VALUE) {
        // 弟啊，你这都不是对象啊
        if (this.contentType == ARRAY_VALUE) {
          if (isNumber(idx)) {
            int idx_num = atoi(idx);
            set_helper_arr(idx_num, value);
          } else {
            g_Game.AlertMessage(at_console, "[ERROR::Value] Cannot modify an array value with a non-integer key.\n");
          }
        } else {
          g_Game.AlertMessage(at_console, "[ERROR::Value] Operator overloads must work with an array or a dictionary.\n");
        }
      } else {
        valueObject[idx] = value;
      }
    }

    string stringify() {
      return Jsona::stringify(this);
    }
  }
}