enum JsonaValueType{
  OBJECT_VALUE = 1,
  ARRAY_VALUE = 2,
  BOOLEAN_VALUE = 4,
  STRING_VALUE = 8,
  INT_VALUE = 16,
  REAL_VALUE = 32,
  NULL_VALUE = 64
}

// JsonaValue 里面存储的数组和对象的元素类型都是 JsonaValue

// 你问为什么？当然是因为静态类型语言不便存储可变类型的变量，同时不整个类不便于得知当前存储的是哪种变量

class JsonaValue{
  private JsonaValueType contentType = NULL_VALUE;
  private int valueInt = 0;
  private string valueString = "";
  private bool valueBoolean = false;
  private double valueReal = 0;
  private array<JsonaValue@>@ valueArray = null;
  private dictionary@ valueObject = null;
  JsonaValue(){
    set();
  }

  JsonaValue(bool value){
    set(value);
  }

  JsonaValue(string value){
    set(value);
  }

  JsonaValue(int value){
    set(value);
  }

  JsonaValue(double value){
    set(value);
  }

  JsonaValue(array<JsonaValue@> value){
    set(value);
  }
  
  JsonaValue(dictionary value){
    set(value);
  }

  private void dangerouslyResetValue(){
    valueInt = 0;
    valueString = "";
    valueBoolean = false;
    valueReal = 0;
    @valueArray = null;
    @valueObject = null;
  }

  JsonaValueType type(){
    return this.contentType;
  }

  bool getBool(){
    return this.valueBoolean;
  }

  string getString(){
    return this.valueString;
  }

  int getInt(){
    return this.valueInt;
  }

  double getReal(){
    return this.valueReal;
  }

  array<JsonaValue@>@ getArray(){
    return @this.valueArray;
  }

  dictionary@ getObject(){
    return @this.valueObject;
  }

  void set(){
    dangerouslyResetValue();
    this.contentType = NULL_VALUE;
  }

  void set(bool value){
    dangerouslyResetValue();
    this.contentType = BOOLEAN_VALUE;
    this.valueBoolean = value;
  }

  void set(string value){
    dangerouslyResetValue();
    this.contentType = STRING_VALUE;
    this.valueString = value;
  }

  void set(int value){
    dangerouslyResetValue();
    this.contentType = INT_VALUE;
    this.valueInt = value;
  }

  void set(double value){
    dangerouslyResetValue();
    this.contentType = REAL_VALUE;
    this.valueReal = value;
  }

  void set(array<JsonaValue@> value){
    dangerouslyResetValue();
    this.contentType = ARRAY_VALUE;
    @this.valueArray = @value; // 注意: 这里使用引用以避免重复深拷贝，同时还可以使数据双向流动
  }
  
  void set(dictionary value){
    this.contentType = OBJECT_VALUE;
    @this.valueObject = @value; // 注意: 这里使用引用以避免重复深拷贝，同时还可以使数据双向流动
  }

  /*
    好耶，是语法糖！
    为了便于嵌套访问数据（比如 arr[0]["key"][0]["key1"]），JsonaValue 会为程序代为访问 array 和 dictionary，并返回相应的 JsonaValue。
  */

  // 代为访问 array
  JsonaValue@ get_opIndex(int idx){
    if(this.contentType != ARRAY_VALUE){
      // 弟啊，你这都不是数组啊
      g_Game.AlertMessage(at_console, "[ERROR::JsonaValue] Cannot access a non-array value as an array value.\n");
      return null;
    }else{
      return cast<JsonaValue@>(valueArray[idx]);
    }
  }

  // 代为访问 dictionary
  JsonaValue@ get_opIndex(string idx){
    if(this.contentType != OBJECT_VALUE){
      // 弟啊，你这都不是对象啊
      g_Game.AlertMessage(at_console, "[ERROR::JsonaValue] Cannot access a non-dictionary value as a dictionary value.\n");
      return null;
    }else{
      return cast<JsonaValue@>(valueObject[idx]);
    }
  }
}