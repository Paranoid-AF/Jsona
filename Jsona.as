#include "JsonaValue"
#include "JsonaTokenizer"
class Jsona{
  private int pos = 0;
  private array<JsonaToken@> tokens;
  private JsonaTokenizer tokenizer;

  JsonaValue@ parse(string str){
    tokens.resize(0);
    pos = 0;
    tokens = tokenizer.parse(str);
    JsonaValue@ head = process();
    return head;
  }

  private JsonaValue@ process(){
    if(tokens.length() < 1){
      g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] No token found in the target string!\n");
    }else{
      if(tokens[pos].getType() == BEGIN_OBJECT){
        return processObject();
      }else if(tokens[pos].getType() == BEGIN_ARRAY){
        return processArray();
      }else if(tokens[pos].getType() == NULL){
        return processNull();
      }else if(tokens[pos].getType() == NUMBER){
        return processNumber();
      }else if(tokens[pos].getType() == STRING){
        return processString();
      }else if(tokens[pos].getType() == BOOLEAN){
        return processBoolean();
      }
    }
    return JsonaValue();
  }

  private bool isElement(JsonaTokenType type){
    return (type == BEGIN_OBJECT || type == BEGIN_ARRAY || type == NULL || type == NUMBER || type == STRING || type == BOOLEAN);
  }

  private JsonaValue@ processBoolean(){
    string val = tokens[pos].getValue();
    bool targetValue = atobool(val);
    return JsonaValue(targetValue);
  }

  private JsonaValue@ processNumber(){
    string val = tokens[pos].getValue();
    if(val.Find(".") == String::INVALID_INDEX){ // Check int or real
      // int
      int targetValue = atoi(val);
      return JsonaValue(targetValue);
    }else{
      // real
      double targetValue = atod(val);
      return JsonaValue(targetValue);
    }
  }

  private JsonaValue@ processNull(){
    return JsonaValue();
  }

  private JsonaValue@ processString(){
    string val = tokens[pos].getValue();
    return JsonaValue(val);
  }

  private JsonaValue@ processObject(){
    dictionary result;
    while(pos < int(tokens.length()) && tokens[pos].getType() != END_OBJECT){
      if(tokens[pos].getType() == SEP_COLON){
        if(pos-1 >= 0 && pos+1 < int(tokens.length()) && tokens[pos-1].getType() == STRING && isElement(tokens[pos+1].getType())){ // has key
          pos++;
          result.set(tokens[pos-1].getValue(), process());
        }else{
          g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] Invalid key-value in an object.\n");
        }
      }
      pos++;
    }
    return JsonaValue(result);
  }

  private JsonaValue@ processArray(){
    array<JsonaValue@> result;
    pos++;
    while(pos < int(tokens.length()) && tokens[pos].getType() != END_ARRAY){
      if(tokens[pos].getType() == SEP_COMMA){
        pos++;
        continue;
      }
      if(isElement(tokens[pos].getType())){
        result.insertLast(process());
      }else{
        g_Game.AlertMessage(at_console, "[ERROR::JsonaMain] Invalid value in an array.\n");
      }
      
      pos++;
    }
    return JsonaValue(result);
  }
}