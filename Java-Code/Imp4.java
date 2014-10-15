
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @Author UrvashiSoni
 */
class Token {

    String token_name;
    String token_id;
    int linenumber;
    String token_value;
    int groupid;

    public int getGroupid() {
        return groupid;
    }

    public void setGroupid(int groupid) {
        this.groupid = groupid;
    }

    public int getLinenumber() {
        return linenumber;
    }

    public void setLinenumber(int nl) {
        this.linenumber = nl;
    }

    public String getToken_id() {
        return token_id;
    }

    public void setToken_id(String token_id) {
        this.token_id = token_id;
    }

    public String getToken_name() {
        return token_name;
    }

    public void setToken_name(String token_name) {
        this.token_name = token_name;
    }

    public String getToken_value() {
        return token_value;
    }

    public void setToken_value(String token_value) {
        this.token_value = token_value;
    }

}

public class Imp4 {

    Token newToken;
    public ArrayList<Character> charInputArray = new ArrayList();
    public LinkedList<Token> tokenList = new LinkedList();
    int index = 0;
    int j = 0;
    int arrsize = 0;
    int count = 0;
    int lineNumber = 1;
    int nextIndex = 0;
    int errorGroupId = 0;
    int groupid = 1;
    String errorMsg = null;

    public void check_ob(char Item) {
        if (Item == '{') {
            newToken = new Token();
            newToken.setToken_name("OB");
            newToken.setToken_value("{");
            newToken.setLinenumber(lineNumber);
            tokenList.add(newToken);
        }
    }

    public void check_cb(char Item) {
        if (Item == '}') {
            newToken = new Token();
            newToken.setToken_name("CB");
            newToken.setToken_value("}");
            newToken.setLinenumber(lineNumber);
            tokenList.add(newToken);

        }
    }

    public void check_equalOperator(char Item) {
        if (Item == '=') {
            newToken = new Token();
            newToken.setToken_name("EQ");
            newToken.setToken_value("=");
            newToken.setLinenumber(lineNumber);
            tokenList.add(newToken);
        }
    }

    public void check_newline() {
        lineNumber++;
        index++;
    }

    public void check_semicolon(char Item) {
        if (Item == ';') {
            newToken = new Token();
            newToken.setToken_name("SC");
            newToken.setToken_value(";");
            newToken.setLinenumber(lineNumber);
            tokenList.add(newToken);

        }
    }

    public void comment() {
        while (charInputArray.get(index) != '\n') {
            index = index + 1;
        }

    }

    private String handleQuotedString() {
        //System.out.println("inside handle quote strng");
        StringBuilder sb = new StringBuilder();
        sb.append(charInputArray.get(index));
        String token;
        char c;
        if (index + 1 < arrsize) {
            index++;
        }
        while ((index < arrsize)) {
            if (charInputArray.get(index) == '"'
                    && charInputArray.get(index - 1) != '\\') {
                sb = sb.append(charInputArray.get(index));
                index++;
                break;
            } else {
                c = charInputArray.get(index);
                //System.out.println("value appended");
                sb = sb.append(c);
                //sb= sb.append('\n');
                index++;
            }

        }
        token = sb.toString();
        return token;
    }

    public void check_otherToken() {
        //System.out.println("iside checktoken");
        boolean openquoteflag = false;
        boolean closequoteflag = false;
        StringBuilder sb = new StringBuilder();
        String token = null;
        while ((index < arrsize)
                && (charInputArray.get(index) != '"')
                && (charInputArray.get(index) != '=')
                && (charInputArray.get(index) != ' ')
                && (charInputArray.get(index) != '\n')
                && (charInputArray.get(index) != '\t')
                && (charInputArray.get(index) != '}')
                && (charInputArray.get(index) != '{')
                && (charInputArray.get(index) != ';')) {
            sb = sb.append(charInputArray.get(index));
            token = sb.toString();
            index++;
        }
        if ((charInputArray.get(index) == '"' && !openquoteflag)) {
            openquoteflag = true;
            token = handleQuotedString();
                //index++;
            //System.out.println("token value after quoted "+token);
            openquoteflag = false;
        }
        newToken = new Token();
        //System.out.println(token);
        newToken.setToken_name("Token");
        newToken.setToken_value(token);
        //System.out.println("token made in searchsas key " + sb.toString());
        newToken.setLinenumber(lineNumber);
        tokenList.add(newToken);

    }

    public void token() {
        for (index = 0; index < charInputArray.size();) {
            char Item = charInputArray.get(index);
            //System.out.println ("read charcer   " + Item);
            switch (Item) {
                case ' ':
                    index++;
                    break;
                case '\t':
                    index++;
                    break;
                case '\n':
                    check_newline();
                    break;
                case '{':
                    check_ob(Item);
                    index++;
                    break;
                case '}':
                    check_cb(Item);
                    index++;
                    break;
                case '#':
                    comment();
                    break;
                case '=':
                    check_equalOperator(Item);
                    index++;
                    break;
                case ';':
                    check_semicolon(Item);
                    index++;
                    break;
                default:
                    check_otherToken();
                    break;

            }
        }

    }

    public boolean match_Pattern(String pattern, String Token) {
        boolean flag = false;
        Pattern Pat = Pattern.compile(pattern);
        Matcher Match = Pat.matcher(Token);
        if (Match.matches()) {
            //System.out.println(Token + "Token");
            flag = true;
        }
        return flag;
    }

    public void traverse() {
        String Token = "";
        boolean eqFlag = false;
        //boolean lookingforkeyFlag = false;
        //boolean foundkeyFlag = false;
        boolean keyFlag = false;
        boolean hostFlag = false;
        String Global_Pattern = "global";
        String Host_Pattern = "host";
        String OB_Pattern = "[{]";
        String CB_Pattern = "}";
        String Hash_Pattern = "#";
        String SC_Pattern = ";";
        String EQ_Pattern = "=";
        String HName_Pattern = "[_a-zA-Z0-9.-]*";
        String Key_Pattern = "[_a-zA-Z][_a-zA-Z0-9]*";
        String Intvalue_Pattern = "[-+]*[0-9]+";
        String Floatvalue_Pattern = "[0-9]+[.][0-9]*";
        String Stringvalue_Pattern = "[a-zA-Z/][_a-zA-Z0-9./-]*";
        String QStringvalue_Pattern = "[\"][^\"].*[\"]";
        // String q1= [a-zA-Z]
        //System.out.println("-------Printing Tokens------------");

        for (Token tokenList1 : tokenList) {
            Token = tokenList1.token_value;
            //System.out.println(Token);
            if (tokenList1.token_value.equals("\\0")) {
                tokenList1.token_name = "NullError";
                tokenList1.groupid = groupid;
            } else if (match_Pattern(Global_Pattern, Token)) {
                // System.out.println("global found,search for ob");
                tokenList1.token_name = "global";
                tokenList1.groupid = groupid;

            } else if (match_Pattern(Host_Pattern, Token)) {
                // System.out.println("Host pattern found");
                tokenList1.token_name = "host";
                hostFlag = true;
                tokenList1.groupid = groupid;

            } else if (hostFlag == true) {
                if (match_Pattern(HName_Pattern, Token)) {
                    // System.out.println("Hostname idicator pattern found");
                    tokenList1.token_name = "Host_indicator";
                    hostFlag = false;
                    tokenList1.groupid = groupid;
                } else {
                    hostFlag = false;
                    tokenList1.token_name = "Host_indicatorError";
                    // System.out.println("Hostname error");
                    tokenList1.groupid = groupid;
                }
            } else if (match_Pattern(OB_Pattern, Token)) {
                //System.out.println("ob found,search for key");
                tokenList1.groupid = groupid;

            } else if (match_Pattern(CB_Pattern, Token)) {
                //System.out.println("CB pattern found");
                tokenList1.token_name = "CB";
                groupid++;
                tokenList1.groupid = groupid;
                //System.out.println("groupid incremented");

            } else if (match_Pattern(SC_Pattern, Token)) {
                //System.out.println("Semicln pattern found");
                tokenList1.token_name = "Semicln";
                tokenList1.groupid = groupid;
            } else if (match_Pattern(EQ_Pattern, Token)) {
                //System.out.println("equal pattern found");
                tokenList1.token_name = "EQ";
                eqFlag = true;
                tokenList1.groupid = groupid;

            } else if (!keyFlag) {
                if (match_Pattern(Key_Pattern, Token)) {
                    //System.out.println("key pattern found");
                    tokenList1.token_name = "KEY";
                    keyFlag = true;
                    tokenList1.groupid = groupid;

                } else {
                    tokenList1.token_name = "ErrorKEY";
                    //System.out.println("Error KEy at line:" + tokenList1.linenumber);
                    keyFlag = true;
                    tokenList1.groupid = groupid;

                }
            } else if (keyFlag == true && eqFlag == true) {
                //System.out.println("Inside Value Match");
                if (match_Pattern(Intvalue_Pattern, Token)) {
                    // System.out.println("Int pattern found");
                    tokenList1.token_name = "IntValue";
                    tokenList1.token_id = "I:";
                    keyFlag = false;
                    eqFlag = false;
                    tokenList1.groupid = groupid;
                } else if (match_Pattern(Floatvalue_Pattern, Token)) {
                    // System.out.println("float value pattern found");
                    tokenList1.token_name = "FloatValue";
                    tokenList1.token_id = "F:";
                    keyFlag = false;
                    eqFlag = false;
                    tokenList1.groupid = groupid;
                } else if (match_Pattern(Stringvalue_Pattern, Token)) {
                    // System.out.println("String value pattern found");
                    tokenList1.token_id = "S:";
                    tokenList1.token_name = "StringValue";
                    keyFlag = false;
                    eqFlag = false;
                    tokenList1.groupid = groupid;
                } else if (match_Pattern(QStringvalue_Pattern, Token)) {
                    //System.out.println("QString value pattern found");
                    tokenList1.token_name = "QStringValue";
                    tokenList1.token_id = "Q:";
                    keyFlag = false;
                    eqFlag = false;
                    tokenList1.groupid = groupid;
                } else {
                    //System.out.println("Value Error at line: " + tokenList1.linenumber);
                    tokenList1.token_name = "Error";
                    tokenList1.token_value = "Error";
                    tokenList1.token_id = "Errorid";
                    keyFlag = false;
                    eqFlag = false;
                    tokenList1.groupid = groupid;
                }
            }

        }
    }

    public String quotedString(int i) {
        String newVal = null;
        boolean qupdate = false;
        String qStringValue = tokenList.get(i).token_value;
        int length = qStringValue.length();
        char[] Value = new char[length];
        Value = qStringValue.toCharArray();
        StringBuilder sb = new StringBuilder();
        for (int k = 0; k < length; k++) {
            if (Value[k] == '\\') {
                if (k + 1 < length) {
                    if (Value[k + 1] == 'n') {
                        sb = sb.append('\n');
                        k++;
                        //System.out.println("new line appended");
                    } else if (Value[k + 1] == 'r') {
                        sb = sb.append('\r');
                        k++;
                    } else if (Value[k + 1] == '"') {
                        sb = sb.append('\"');
                        k++;
                    } else if (Value[k + 1] == '\\') {
                        sb = sb.append('\\');
                        k++;
                    }

                }

            } else {
                sb = sb.append(Value[k]);
            }
        }
        newVal = sb.toString();
        return newVal;
    }

    public String updateToken(int i) {
        String token = tokenList.get(i).token_name;
        return token;
    }

    public void parse_assignment(int i, int keyLineNumber) {

        //System.out.println("Inside Parse assignmnet");
        //System.out.println("groupid: "+tokenList.get(nextIndex).groupid);
        String tokenname = tokenList.get(i).token_name;
        //System.out.println(tokenname);
        int eqLineNumber = tokenList.get(i).getLinenumber();
        int valueLineNumber = 0;
        switch (tokenname) {
            case "EQ":
                nextIndex++;
                if (checkindex(nextIndex)) {
                    valueLineNumber = tokenList.get(nextIndex).getLinenumber();
                    if (tokenList.get(nextIndex).token_name.contains("Value")
                            && keyLineNumber == valueLineNumber) {
                        nextIndex++;
                        if (checkindex(nextIndex)) {
                            String nextToken = tokenList.get(nextIndex).token_name;
                            //System.out.println(nextToken);
                            switch (nextToken) {
                                case "CB":
                                    nextIndex++;
                                    if (checkindex(nextIndex)) {
                                        parseCB(nextIndex);
                                    } else {
                                        //System.out.println("File Complete ");
                                        break;
                                    }
                                    break;
                                case "KEY":
                                    //System.out.println("key f ");
                                    keyLineNumber = tokenList.get(nextIndex).getLinenumber();
                                    nextIndex++;
                                    if (checkindex(nextIndex)) {

                                        parse_assignment(nextIndex, keyLineNumber);

                                    } else {
                                        errorGroupId = tokenList.get(nextIndex).groupid;
                                        //System.out.println("groupid: "+tokenList.get(nextIndex-1).groupid);
                                        //System.out.println("7Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                                        errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                                    }
                                    break;
                                default:
                                    errorGroupId = tokenList.get(nextIndex).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                                    //            System.out.println("5Error:P:  " + tokenList.get(nextIndex).linenumber);
                                    errorMsg = "Err:P:" + tokenList.get(nextIndex).linenumber + "\n";
                            }

                        } else {
                            errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                            //       System.out.println("18Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                            errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                        }
                    } else {
                        errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                        //  System.out.println("17Error:P: " + tokenList.get(nextIndex-1).linenumber);
                        errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                    }
                } else {
                    errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    System.out.println("error group id:" + errorGroupId);
                    System.out.println("16Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                    errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                }
                break;
            default:
                errorGroupId = tokenList.get(nextIndex - 1).groupid;
                // System.out.println("error group id:" + errorGroupId);
                //System.out.println("15Error:P: " + tokenList.get(nextIndex-1).linenumber);
                errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";

        }

    }

    private void parseHostGroup(int i) {

        String token = tokenList.get(i).getToken_name();
        //System.out.println(token);
        switch (token) {
            case "Host_indicator":
                //System.out.println("inside host indicator check");
                nextIndex++;
                if (checkindex(nextIndex)) {
                    groupObCb(nextIndex);
                } else {
                    errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                    //System.out.println("13Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                    errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                }
                break;
            default:
                errorGroupId = tokenList.get(nextIndex).groupid;
                //System.out.println("error group id:" + errorGroupId);
                //System.out.println("14Error:P: " + tokenList.get(nextIndex).linenumber);
                errorMsg = "Err:P:" + tokenList.get(nextIndex).linenumber + "\n";
        }

    }

    private void parseCB(int i) {

        // System.out.println("Inside Parse CB");
        String token = tokenList.get(i).token_name;
        //System.out.println(token);
        switch (token) {
            case "Semicln":
                //System.out.println("Inside Semicln");
                nextIndex++;
                if (checkindex(nextIndex)) {

                    if (tokenList.get(nextIndex).token_name.equals("host")) {
                        nextIndex++;
                        if (checkindex(nextIndex)) {
                            //System.out.println("now going to host indicator check ");
                            parseHostGroup(nextIndex);
                        } else {
                            errorGroupId = tokenList.get(nextIndex - 1).groupid;
                            //System.out.println("error group id:" + errorGroupId);
                            //System.out.println("12Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                            errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                        }
                    } else {
                        errorGroupId = tokenList.get(nextIndex - 1).groupid;
                        //System.out.println("error group id:" + errorGroupId);
                        //System.out.println("9Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                        errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                    }
                } else {
                    break;
                    //System.out.println("File Complete after semicln");
                }
                break;

            case "host":
                nextIndex++;
                if (checkindex(nextIndex)) {
                    parseHostGroup(nextIndex);
                } else {
                    errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                    //System.out.println("11Error:P: " + tokenList.get(nextIndex - 1).linenumber);
                    errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                }
                break;
            default:
                errorGroupId = tokenList.get(nextIndex).groupid;
                //System.out.println("error group id:" + errorGroupId);
                //System.out.println("10Error:P: " + tokenList.get(nextIndex).linenumber);
                errorMsg = "Err:P:" + tokenList.get(nextIndex).linenumber + "\n";
        }

        //else System.out.println("cbbbparsing error at line: " + tokenList.get(i-1).linenumber);
    }

    public boolean checkindex(int i) {
        if (i >= tokenList.size()) {
            return false;
        } else {
            return true;
        }
    }

    public void groupObCb(int i) {

        //System.out.println("i is " + i + (" ") + tokenList.size());
        String tokenName = tokenList.get(i).token_name;
        if (tokenName.equals("OB")) {
            nextIndex = nextIndex + 1;
            if (checkindex(nextIndex)) {
                tokenName = tokenList.get(nextIndex).token_name;
                switch (tokenName) {
                    case "CB":
                        nextIndex++;
                        if (checkindex(nextIndex)) {
                            parseCB(nextIndex);
                        } else {
                            //System.out.println("1File Complete ");
                            break;
                        }
                        break;
                    case "KEY":
                        //System.out.println("key f ");
                        int keyLineNumber = tokenList.get(nextIndex).getLinenumber();
                        nextIndex++;
                        if (checkindex(nextIndex)) {
                            parse_assignment(nextIndex, keyLineNumber);
                        } else {
                            errorGroupId = tokenList.get(nextIndex - 1).groupid;
                            //System.out.println("error group id:" + errorGroupId);
                            //System.out.println("Err:P:" + tokenList.get(nextIndex - 1).linenumber+"\n");
                            errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
                        }
                        break;
                    default:
                        errorGroupId = tokenList.get(nextIndex).groupid;
                        //System.out.println("error group id:" + errorGroupId);
                        //System.out.println("Err:P:" + tokenList.get(nextIndex).linenumber);
                        errorMsg = "Err:P:" + tokenList.get(nextIndex).linenumber + "\n";
                }
            } else {
                errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                //System.out.println("4Error:P:" + tokenList.get(nextIndex-1).linenumber);
                errorMsg = "Err:P:" + tokenList.get(nextIndex - 1).linenumber + "\n";
            }
        } else {
            errorGroupId = tokenList.get(i).groupid;
            //System.out.println("error group id:" + errorGroupId);
            //System.out.println("6Error:P:" + tokenList.get(i).linenumber);
            errorMsg = "Err:P:" + tokenList.get(i).linenumber + "\n";
        }
    }

    public void parser() {
        nextIndex = 0;
        //System.out.println("------------Parsing start-----------");
        if (checkindex(nextIndex)) {
            String token = tokenList.get(nextIndex).token_name;
            if (token.equals("global")) { //1st conditon pass
                nextIndex++;
                if (checkindex(nextIndex)) {
                    groupObCb(nextIndex);

                } else {
                    //System.out.println("Err:P:1\n"); 
                    errorGroupId = tokenList.get(nextIndex - 1).groupid;
                    //System.out.println("error group id:" + errorGroupId);
                    errorMsg = "Err:P:1\n";

                }
            } else {
                errorGroupId = tokenList.get(0).groupid;
                //System.out.println("error group id:" + errorGroupId);
                //System.out.println("2Error:P:" + tokenList.get(0).linenumber);
                errorMsg = "Err:P:" + tokenList.get(0).linenumber + "\n";
            }
        } else {
            //System.out.println("Err:P:" + 1+"\n");
            //System.out.println("error group id:" + errorGroupId);
            errorMsg = "Err:P:" + 1 + "\n";
        }
    }

    /* if (qStringValue.contains("\\")) {
     newVal = qStringValue.replace("\\", "");
     qupdate= true;
     System.out.println(newVal);
     }
        
     if (qStringValue.contains("\\\\")) {
     newVal = qStringValue.replace("\\\\", "\\");
     System.out.println(newVal);
     return newVal;
     }
        

        

     if (qStringValue.contains("\\\"")) {
     System.out.println("4");
     newVal = qStringValue.replace("\\\"", "\"");
     qupdate= true;
     System.out.println(newVal);
     return newVal;
     }

     if (qStringValue.contains("\\r")) {
     System.out.println("5");
     newVal = qStringValue.replace("\\r", "\r");
     qupdate= true;
     System.out.println(newVal);
     }
        
     if (qupdate)
     return newVal;
     else*/
    public boolean checkOverride(int i) {
        boolean duplicateFlag = false;
        String keyValue = tokenList.get(i).token_value;
        int currentGroupId = tokenList.get(i).groupid;
        int checkGroupId = 1;

        for (int j = 0; j <= i - 1; j++) {

            if (keyValue.equals(tokenList.get(j).token_value)
                    && (currentGroupId == tokenList.get(j).groupid)) {
                duplicateFlag = true;

            } else if (keyValue.equals(tokenList.get(j).token_value)
                    && (tokenList.get(j).groupid == 1)) {
                duplicateFlag = true;
            }
        }

        return duplicateFlag;
    }

    public void output() {
        String temp;
        String newVal = null;
        int i = 0;
        String tokenIdofThisKey;
       //System.out.println("errorGroup id "+errorGroupId);
        //System.out.println("GLOBAL");
        while (i < tokenList.size() && tokenList.get(i).groupid != errorGroupId) {

            if ((tokenList.get(i).token_name).equals("global")) {
                System.out.println("GLOBAL:");
                //System.out.println("group id "+tokenList.get(i).groupid);
            } else if ((tokenList.get(i).token_name).equals("KEY")) {
                tokenIdofThisKey = tokenList.get(i + 2).token_id;
                if (checkOverride(i)) {
                    System.out.print("    " + tokenIdofThisKey + "O:" + tokenList.get(i).token_value);
                } else {
                    System.out.print("    " + tokenIdofThisKey + ":" + tokenList.get(i).token_value);
                }// System.out.println("group id "+tokenList.get(i).groupid);
            } else if ((tokenList.get(i).token_name).contains("Value")) {
                if ((tokenList.get(i).token_id).equals("Q:")) {
                    newVal = quotedString(i);
                    System.out.println(":\"\"" + newVal + "\"\"");
                } else {
                    System.out.println(":" + tokenList.get(i).token_value);
                }
                // System.out.println("group id "+tokenList.get(i).groupid);
            } else if ((tokenList.get(i).token_name).equals("host")) {
                System.out.print("HOST");
                //  System.out.println("group id "+tokenList.get(i).groupid);
            } else if ((tokenList.get(i).token_name).equals("Host_indicator")) {
                System.out.println(" " + tokenList.get(i).token_value + ":");
                //  System.out.println("group id "+tokenList.get(i).groupid);
            }
            i++;
        }
       
        if (null != errorMsg) {
            System.out.println(errorMsg);
        }else
             System.out.print("\n");
        
    }

    public void readFromFile(String filename) {

        FileInputStream fileInput;
        try {
            fileInput = new FileInputStream(filename);
            int r;
            while ((r = fileInput.read()) != -1) {
                char c = (char) r;
                //  System.out.print(c);
                charInputArray.add(c);
                arrsize++;
            }
            fileInput.close();
        } catch (Exception e) {
            System.out.println("ERR:F:\n");
            System.exit(0);
        }
    }

    public static void main(String[] args) throws FileNotFoundException, IOException {
        // TODO code application logic here

        Imp4 m = new Imp4();
        m.readFromFile("test.cfg”);// done
        m.token();// inprocess
        m.traverse();
        m.parser();
        m.output();
       
    }

}
