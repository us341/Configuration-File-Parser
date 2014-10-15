with Text_IO;
use Text_IO;
with IO_EXCEPTIONS;
use IO_EXCEPTIONS;

procedure imp3ada is

   package Int_IO is new Text_IO.Integer_IO(INTEGER);
   use Int_IO;
   Index: Integer:=1;
   fileErrorFlag : Boolean :=False;
	MY_ARRAY : Array(1..20000) of character;
	array_Size :   Integer :=1;
	valueIndex : Integer :=1;
	tokenArrayIndex: Integer :=1;
	T:Integer:=1;
	line_number: Integer :=1;
	errorFlag : Boolean := FALSE;
	parsingComplete : Boolean := FALSE;
	valueFound : Boolean := FALSE;
	newLineFound : Boolean :=False;
	errorMessage : String(1..6):="ERR:P:";
	errorGroupId : Integer :=0;
	errorLineNumber : Integer := 0;
	groupId : Integer :=1;
	Subtype capsOn is Character Range 'A'..'Z';
    Subtype capsOff is Character Range 'a'..'z';
    Subtype int is character Range '0' .. '9';
    
    --subtype Number_Base is Integer range 1 .. 100;
	--Default_Width : Field := Num'Width;
	---Default_Base  : Number_Base := 10;
	
	type Token_Record is
    record
         token_Name: String(1..3);
         token_Value: String(1..200);
         tokenId : Character ;
         lineNumber: Integer :=1;
         tokenGroupId : Integer ;
         tokenCharCount : Integer ;
    end record;
    Token_List: Array(1..500) of Token_Record;
	
	procedure search_CBorKey;
	procedure search_OB;
	
	
	
	procedure skip_Spaces is
	Char:Character;
	
	begin
		while(Index<array_Size) loop	--this loop is to traverse and increment index through comments,newlines,tabs and white spaces
			Char:= MY_ARRAY(Index);
			case Char is
			when ' '|ASCII.HT	=> 			
											Index:=Index+1;
											
			when ASCII.LF 		=> 			
											line_number:=line_number+1;
											newLineFound := TRUE;
											Index:=Index+1;  
											
			when '#'			=> 			--Put("Comment found");
				 							--New_Line(1);
         					   				while MY_ARRAY(Index) /= ASCII.LF loop
         					   				--Put(MY_ARRAY(Index));
         					   				
         					   				Index:=Index+1;  
         					   				
         					   				end loop;	
			when others			=>     --Put("exit space loop now...character encountered");
									--New_Line(1);
									exit;
																
			end case;
		end loop;	
	end skip_Spaces;
		

    
	
   	procedure ReadfromFile is
	package Int_IO is new Text_IO.Integer_IO(INTEGER);
   	use Int_IO;
	My_File  : FILE_TYPE;
   	One_Char : CHARACTER;
   	begin
   		open(My_File,In_File,"test.cfg");
   		
  		while not  End_Of_File(My_File) loop    
     		 if not End_Of_Line(My_File) then
        	 	--Put("<- not end of line  ");
        	 	Get(My_File,One_Char);
        	 	My_Array(array_Size):=One_Char;
        	 	--My_Array(array_Size):=ASCII.LF;
     		 	array_Size:=array_Size+1;
     		 else 
     		 --Put("<---End Of Line Found");
     		 My_Array(array_Size):=ASCII.LF;
     		 --My_Array(array_Size):=One_Char;
     		 array_Size:=array_Size+1;
     		 Skip_line(My_File); 
			 end if;	
		end loop;		
		Close(My_File);
		exception
         when IO_EXCEPTIONS.NAME_ERROR => Put("ERR:F:"); New_Line(1); fileErrorFlag :=True;
	end ReadfromFile;
	
	
	function check_keyOverride(tokenIndex : Integer) return boolean is
	currentGroupId : Integer ;
	currentKeyValue : String(1..200);
	checkOverrideIndex : Integer :=1;
	returnBoolean : Boolean := FALSE;
	begin
	--Put("inside check key override");
	currentGroupId := Token_List(tokenIndex).tokenGroupId;
	currentKeyValue := Token_List(tokenIndex).token_Value;
	--Put(currentGroupId);
	while checkOverrideIndex<tokenIndex loop
		if currentKeyValue = Token_List(checkOverrideIndex).token_Value 
		and Token_List(checkOverrideIndex).tokenGroupId = 1 then
			returnBoolean := TRUE;
		end if;
		if currentKeyValue = Token_List(checkOverrideIndex).token_Value 
		and Token_List(checkOverrideIndex).tokenGroupId = currentGroupId then
			returnBoolean := TRUE;
		end if;
		checkOverrideIndex := checkOverrideIndex+1;
	end loop; 
	return returnBoolean;
	end check_keyOverride;
	
	
	Procedure printarray is
	tokenIndex :Integer:=1;
	tokenName : String(1..3);
	i : Integer :=1;
	count : Integer :=1;
	Raw_Image     : constant String := Integer'Image(errorLineNumber);
	Sliced_Image  : constant String := Raw_Image(2 .. Raw_Image'Last);
	begin
	--Put("-------Printing groups and key value pairs------------");

	
	 while tokenIndex < tokenArrayIndex and errorGroupId /= (Token_List(tokenIndex).tokenGroupId) loop
	 	tokenName := Token_List(tokenIndex).token_Name;
	 	
	 	if tokenName="Glo" then
	 		Put("GLOBAL:");
	 		--Put(Token_List(tokenIndex).tokenGroupId);
	 		New_Line(1); 
	 		tokenIndex:=tokenIndex+1;
	 		end if;
	 		
	 	if tokenName="Hos" then
	 	
	 		Put("HOST ");
	 		tokenIndex:=tokenIndex+1;
	 		i:= 1;
	 		while i<Token_List(tokenIndex).tokenCharCount loop
	 		Put(Token_List(tokenIndex).token_Value(i));
	 		i:=i+1;
	 		end loop;
	 		Put(":");
	 		--Put(Token_List(tokenIndex).tokenGroupId);
	 		New_Line(1); 
	 		tokenIndex:=tokenIndex+1;
	 	end if;
	 	
	 	if tokenName="Key" then
	 	i:=1;
	 			Put("    ");
	 			Put(Token_List(tokenIndex+1).tokenId);
	 			Put(":");
	 			if check_keyOverride(tokenIndex) then
	 			Put("O:");
	 			else
	 			Put(":");
	 			end if;
	 			i:=1;
	 			while i<Token_List(tokenIndex).tokenCharCount loop
	 			Put(Token_List(tokenIndex).token_Value(i));
	 			--Put(Token_List(tokenIndex).tokenGroupId);
	 			i:=i+1;
	 			end loop;
	 			Put(":");
	 			tokenIndex:=tokenIndex+1;
	 			if Token_List(tokenIndex).tokenId = 'Q' then
	 				Put('"');
	 				Put('"');
	 				Put('"');
	 				i:=1;
	 				while i<Token_List(tokenIndex).tokenCharCount loop
	 			Put(Token_List(tokenIndex).token_Value(i));
	 			--Put(Token_List(tokenIndex).tokenGroupId);
	 			i:=i+1;
	 			end loop;
	 				Put('"');
	 				Put('"');
	 				Put('"');
	 			else
	 				i:=1;
	 				while i<Token_List(tokenIndex).tokenCharCount loop
	 			Put(Token_List(tokenIndex).token_Value(i));
	 			--Put(Token_List(tokenIndex).tokenGroupId);
	 			i:=i+1;
	 			end loop;
	 			end if;
	 		--Put(Token_List(tokenIndex).tokenGroupId);
	 			New_Line(1); 
	 		if tokenIndex < tokenArrayIndex then
	 		tokenIndex:=tokenIndex+1;
	 		end if;
	 	end if;
	 	 count:= count+1;
	 end loop;
	 
	 if errorFlag = TRUE then
	 	Put(errorMessage);
	 	Put(Sliced_Image);
	 	New_Line(1);
	 end if;
	end printarray;
	
	
	procedure search_ValueQuotes is
	quoteValueCount : Integer;
		stringIndex : Integer :=1;
		possibleErrorLine : Integer;
	begin
	
		--Put("------------search value quotes-----------------");
		quoteValueCount:=1;
		possibleErrorLine:=line_number;
		if Index+1<array_Size then
			Index:=Index+1;
		end if;
		
		while Index<array_Size loop
			if MY_ARRAY(Index) = '"' 
				and MY_ARRAY(Index-1) /= '\' 
				
				then 
				--Put("end quotes found");
				Index:=Index+1;
				exit;
				
			else
				case MY_ARRAY(Index) is
				
					when '\' => --Put("Backslash found");
							if(Index+1<array_Size) then
								Index:=Index+1;
								case MY_ARRAY(Index) is
									when 'n' => Token_List(tokenArrayIndex).token_Value(stringIndex):=ASCII.LF;
												--Put("New Line appended");
			 									stringIndex:=stringIndex+1;
		 										Index:=Index+1;
		 										quoteValueCount:=quoteValueCount+1;
		 							when 'r' => Token_List(tokenArrayIndex).token_Value(stringIndex):=ASCII.CR;
												--Put("New Line appended");
			 									stringIndex:=stringIndex+1;
		 										Index:=Index+1;
		 										quoteValueCount:=quoteValueCount+1;
		 							when '\' => Token_List(tokenArrayIndex).token_Value(stringIndex):='\';
												--Put("backslash appended");
			 									stringIndex:=stringIndex+1;
		 										Index:=Index+1;
		 										quoteValueCount:=quoteValueCount+1;
		 							when '"' => 
		 										Token_List(tokenArrayIndex).token_Value(stringIndex):='"';
												--Put("backslash appended");
			 									stringIndex:=stringIndex+1;
		 										Index:=Index+1;		
		 										quoteValueCount:=quoteValueCount+1;	
		 							when others=> Token_List(tokenArrayIndex).token_Value(stringIndex):=MY_ARRAY(Index);
												--Put("normal letters appended");
			 									stringIndex:=stringIndex+1;
		 										Index:=Index+1;
		 										quoteValueCount:=quoteValueCount+1;
								end case;
							
							end if;
							
					when ASCII.LF => --Put("new line feed found in quoted string");
									 errorFlag :=True;
									 errorGroupId := groupId;
									 errorLineNumber :=possibleErrorLine;
									 exit;
									 
					
									 
					when others => Token_List(tokenArrayIndex).token_Value(stringIndex):=MY_ARRAY(Index);
									stringIndex:=stringIndex+1;
		 										Index:=Index+1;
		 										quoteValueCount:=quoteValueCount+1;
				end case;
			end if;
		end loop;
		if errorFlag =FALSE THEN 
		--Put(Token_List(tokenArrayIndex).token_Value);
		Token_List(tokenArrayIndex).token_Name:="Val";
		Token_List(tokenArrayIndex).tokenId:='Q';
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			Token_List(tokenArrayIndex).tokenCharCount:=quoteValueCount;
			tokenArrayIndex:=tokenArrayIndex+1;
			valueIndex:=1;
			search_CBorKey;
		end if;
	end search_ValueQuotes;
	
	
	procedure search_ValueInt is
	intValueCount : Integer;
	stringIndex : Integer :=1;
	dotCount : Integer :=0;
	signIndex : Integer ;
	startIndex : Integer ;
	possibleErrorLine : Integer;
	dotErrorFlag : Boolean := FALSE;
	begin
	possibleErrorLine:=line_number;
		startIndex:=Index;
		signIndex:=startIndex;
		intValueCount:=1;
		while Index<array_Size
			 and MY_ARRAY(Index) /= '"'
		 	 and MY_ARRAY(Index) /= '='
		 	 and MY_ARRAY(Index) /= '{'
		 	 and MY_ARRAY(Index) /= '}'
		 	 and MY_ARRAY(Index) /= '#'
		 	 and MY_ARRAY(Index) /= ' '
		 	 and MY_ARRAY(Index) /= ';' 
		 	 and MY_ARRAY(Index) /= ASCII.LF 
		 	 and MY_ARRAY(Index) /= ASCII.HT		 
		   loop
		   	if MY_ARRAY(Index) in int
		   	or MY_ARRAY(Index) = '.'
		   	or MY_ARRAY(Index) = '-'
		   	or MY_ARRAY(Index) = '+'
		   		then
		   			if MY_ARRAY(Index) = '.'  then
		   				if  MY_ARRAY(Index-1) /= '+' and MY_ARRAY(Index-1) /= '-' then
		   				dotCount:=dotCount+1;
		   				else
		   					dotErrorFlag := TRUE;
		   					exit;
		   				end if;
		   			end if;
		   			
		   			if MY_ARRAY(Index) = '+' 
		   			or MY_ARRAY(Index) = '-' 
		   			then
		   				signIndex:=Index;
		   			end if;
		    		--Put("inside while loop of int value search");
		   			--New_Line(1);
		 			Token_List(tokenArrayIndex).token_Value(valueIndex):=MY_ARRAY(Index);
			 		valueIndex:=valueIndex+1;
		 			Index:=Index+1;
		 			intValueCount:=intValueCount+1;
		 		else
		 			--Put("wrong int value found   lets check what is next");
		 		 	valueIndex:=1;
		 		 	exit;
		   		end if;	
		end loop;
		if valueIndex > 1
		 and dotCount < 2
		 and signIndex = startIndex 
		 and dotErrorFlag = FALSE then
			--Put("int or float found");
			valueFound := True;
			--Put("inside intvalueFoundTrue");
			--Put(Token_List(tokenArrayIndex).token_Value);
			if dotCount = 0 then
			--Put("Integer found");
			Token_List(tokenArrayIndex).tokenId:='I';
			else
			--Put("Float found");
			Token_List(tokenArrayIndex).tokenId:='F';
			end if;
			Token_List(tokenArrayIndex).token_Name:="Val";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			Token_List(tokenArrayIndex).tokenCharCount:=intValueCount;
			tokenArrayIndex:=tokenArrayIndex+1;
			valueIndex:=1;
			search_CBorKey;
		else
			--Put("invalid/missing value");
			errorGroupId := groupId;
			errorFlag := TRUE;
			errorLineNumber := possibleErrorLine;	
		end if; 		
		
	end search_ValueInt;
	
			
	procedure search_ValueString is
	stringValueCount : Integer;
	possibleErrorLine : Integer;
	nextLineCheckForKeyValue : Integer :=1;
	begin
	stringValueCount:=1;
	possibleErrorLine:=line_number;
	while Index<array_Size
			 and MY_ARRAY(Index) /= '"'
		 	 and MY_ARRAY(Index) /= '='
		 	 and MY_ARRAY(Index) /= '{'
		 	 and MY_ARRAY(Index) /= '}'
		 	 and MY_ARRAY(Index) /= '#'
		 	 and MY_ARRAY(Index) /= ' '
		 	 and MY_ARRAY(Index) /= ';' 
		 	 and MY_ARRAY(Index) /= ASCII.LF 
		 	 and MY_ARRAY(Index) /= ASCII.HT		 
		   loop
		   	if MY_ARRAY(Index) in capsOn
		   		or MY_ARRAY(Index) in capsOff
		   		or MY_ARRAY(Index) in int
		   		or MY_ARRAY(Index) = '/'
		   		or MY_ARRAY(Index) = '.'
		   		or MY_ARRAY(Index) = '-'
		   		or MY_ARRAY(Index) = '_'
		   		then
		    		--Put("inside while loop of value search");
		   			--New_Line(1);
		 			Token_List(tokenArrayIndex).token_Value(valueIndex):=MY_ARRAY(Index);
			 		valueIndex:=valueIndex+1;
		 			Index:=Index+1;
		 			stringValueCount:=stringValueCount+1;
		 		else
		 			--Put("wrong value found   lets check what is next");
		 		 	valueIndex:=1;
		 		 	exit;
		   		end if;	
		end loop;
		if valueIndex > 1 then
		--Put("string index greater than one found");
			valueFound := True;
			--Put("inside valueFoundTrue");
			--Put(Token_List(tokenArrayIndex).token_Value);
			Token_List(tokenArrayIndex).tokenId:='S';
			Token_List(tokenArrayIndex).token_Name:="Val";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			Token_List(tokenArrayIndex).tokenCharCount:=stringValueCount;
			tokenArrayIndex:=tokenArrayIndex+1;
			valueIndex:=1;
			search_CBorKey;
			else
			--Put("invalid/missing value");
			errorGroupId := groupId;
			errorFlag := TRUE;	
			errorLineNumber:=possibleErrorLine;
		end if; 		
	end search_ValueString;
		
			
	procedure Search_Value is
	Char: Character;
	possibleErrorLine : Integer;
	begin
	 --Put("----------Search_Value--------------");
	 --New_Line(1);
	 possibleErrorLine:=line_number;
	 	while(Index+1<array_Size) loop	--this loop is to traverse and increment index through comments,newlines,tabs and white spaces
			Char:= MY_ARRAY(Index);
			case Char is
			when ' '|ASCII.HT	=> 			Index:=Index+1;
			when '#'			=> 			--Put("Comment found");
				 							--New_Line(1);
         					   				while MY_ARRAY(Index) /= ASCII.LF loop
         					   				--Put(MY_ARRAY(Index));
         					   				Index:=Index+1;  
         					   				end loop;	
			when others			=>     --Put("exit space loop now...character encountered");
									--New_Line(1);
									exit;
																
			end case;
		end loop;
		
		--check if first character of value if valid or not
		if MY_ARRAY(Index) in capsOn
		  or MY_ARRAY(Index) in capsOff
		  or MY_ARRAY(Index) ='/' then
		  search_ValueString;
		  else
		  	if MY_ARRAY(Index) in int
		  	or MY_ARRAY(Index) ='+'
		  	or MY_ARRAY(Index) = '-'
		  	 then
		  	search_ValueInt;
		  	else
		  		if MY_ARRAY(Index) = '"'
		  		 then
		  		 search_ValueQuotes;
		  		 else
		  			--Put("invalid/missing value");
					errorGroupId := groupId;
					errorFlag := TRUE;
					errorLineNumber :=possibleErrorLine;
				 end if;
			 end if;
		end if;
		  		
		
	end Search_Value;	
	
	procedure search_Eq is
	Char: Character;
	possibleErrorLine : Integer;
	begin
		 --Put("----------Search_Equal--------------");
		 --New_Line(1);
		 possibleErrorLine:=line_number;
		while(Index+1<array_Size) loop	--this loop is to traverse and increment index through comments,newlines,tabs and white spaces
			Char:= MY_ARRAY(Index);
			case Char is
			when ' '|ASCII.HT	=> 			Index:=Index+1;
			when '#'			=> 			--Put("Comment found");
				 							--New_Line(1);
         					   				while MY_ARRAY(Index) /= ASCII.LF loop
         					   				--Put(MY_ARRAY(Index));
         					   				Index:=Index+1;  
         					   				end loop;	
			when others			=>     --Put("exit space loop now...character encountered");
									--New_Line(1);
									exit;
																
			end case;
		end loop;
		Char:= MY_ARRAY(Index);
		if Char = '=' then
			--Put("Equal found");
			if Index+1<array_Size then
				Index:=Index+1;
				search_Value;
			end if;
		else 
			--Put("Error equal not found");
			errorGroupId := groupId;
			errorFlag := TRUE;
			errorLineNumber:=possibleErrorLine;
			
		end if;
				
	end search_Eq;
	
	procedure Search_Key is
	stringIndex : Integer :=1;
	keyCharCount : Integer ;
	possibleErrorLine : Integer;
	begin
	 --Put("Search_Key");
	 possibleErrorLine:=line_number;
	 keyCharCount := 1;
		   --check if first character of expected key is character or underscore
		  if MY_ARRAY(Index) in capsOn
		  or MY_ARRAY(Index) in capsOff
		  or MY_ARRAY(Index) ='_' then 
			while Index<array_Size
			 and MY_ARRAY(Index) /= '"'
		 	 and MY_ARRAY(Index) /= '='
		 	 and MY_ARRAY(Index) /= '{'
		 	 and MY_ARRAY(Index) /= '}'
		 	 and MY_ARRAY(Index) /= '#'
		 	 and MY_ARRAY(Index) /= ' '
		 	 and MY_ARRAY(Index) /= ';' 
		 	 and MY_ARRAY(Index) /= ASCII.LF 
		 	 and MY_ARRAY(Index) /= ASCII.HT		 
		   loop
		   		--check key doesn't have any invalid key character
		   		if MY_ARRAY(Index) in capsOn
		   		or MY_ARRAY(Index) in capsOff
		   		or MY_ARRAY(Index) in int
		   		or MY_ARRAY(Index) = '_'
		   		 then
		   		 	--Put("inside while loop of key search");
		   			--New_Line(1);
		 			Token_List(tokenArrayIndex).token_Value(stringIndex):=MY_ARRAY(Index);
			 		stringIndex:=stringIndex+1;
		 			Index:=Index+1;
		 			keyCharCount:=keyCharCount+1;
		 		 else
		 		 	stringIndex:=1;
		 		 	exit;
		   		end if;	
		  end loop;	
		 end if;
		if stringIndex>1 then	--this means that the first character while searching for key was valid
			--Put(Token_List(tokenArrayIndex).token_Value);
			Token_List(tokenArrayIndex).token_Name:="Key";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			Token_List(tokenArrayIndex).tokenCharCount:=keyCharCount;
			tokenArrayIndex:=tokenArrayIndex+1;
			stringIndex:=1;
			search_Eq;
		else
			--Put("invalid/missing key");
			errorGroupId := groupId;
			errorFlag := TRUE;
			errorLineNumber:=possibleErrorLine;
			
		end if; 	
	end Search_Key;
	
	
	
	
	procedure search_HostIndicator is
	hostCharCount : Integer ;
	stringIndex : Integer :=1;
	possibleErrorLine : Integer;
	begin 
	--Put("---------search Host indicator-------------");
	hostCharCount:=1;
	skip_Spaces;
	while Index<array_Size
			 and MY_ARRAY(Index) /= '"'
		 	 and MY_ARRAY(Index) /= '='
		 	 and MY_ARRAY(Index) /= '{'
		 	 and MY_ARRAY(Index) /= '}'
		 	 and MY_ARRAY(Index) /= '#'
		 	 and MY_ARRAY(Index) /= ' '
		 	 and MY_ARRAY(Index) /= ';' 
		 	 and MY_ARRAY(Index) /= ASCII.LF 
		 	 and MY_ARRAY(Index) /= ASCII.HT		 
		   loop
		   	if MY_ARRAY(Index) in capsOn
		   		or MY_ARRAY(Index) in capsOff
		   		or MY_ARRAY(Index) in int
		   		or MY_ARRAY(Index) = '_'
		   		or MY_ARRAY(Index) = '.'
		   		or MY_ARRAY(Index) = '-'
		   		 then
		    	--Put("inside while loop of host indicator search");
		   		 --New_Line(1);
		 		Token_List(tokenArrayIndex).token_Value(stringIndex):=MY_ARRAY(Index);
			 	stringIndex:=stringIndex+1;
		 		Index:=Index+1;
		 		hostCharCount:=hostCharCount+1;
		 		else
		 		 	stringIndex:=1;
		 		 	exit;
		   		end if;	
		end loop;	
		
		if stringIndex>1 then	--this means that the first character while searching for hostindicator was valid
			--Put(Token_List(tokenArrayIndex).token_Value);
			Token_List(tokenArrayIndex).token_Name:="Hni";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			Token_List(tokenArrayIndex).tokenCharCount:=hostCharCount;
			tokenArrayIndex:=tokenArrayIndex+1;
			stringIndex:=1;
			search_OB;
		else
			--Put("invalid/missing hostNameIndicator");
			possibleErrorLine:=line_number;
			errorGroupId := groupId;
			errorFlag := TRUE;
			errorLineNumber:=possibleErrorLine;
			
		end if; 	
	end search_HostIndicator;
	
	procedure Search_Host is
	Char: Character;
	possibleErrorLine : Integer;
	begin
	--Put("-----------Search Host---------");
	
	skip_Spaces;
	Char:= MY_ARRAY(Index);
	--Put(Index); Put(" "); Put(array_Size);
	
	if Index = array_Size then
	--Put("Parsing complete and file complete");
	parsingComplete:=True;
	else
		if Index+3< array_Size and My_Array(Index) = 'h'  then
			
			if My_Array(Index) = 'h' 
			and My_Array(Index+1) = 'o'
			and My_Array(Index+2) = 's'
			and My_Array(Index+3) = 't'
			 then 
			--Put("host found");
			--New_Line(1);
			Token_List(tokenArrayIndex).token_Name:="Hos";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			tokenArrayIndex:=tokenArrayIndex+1;
			Index:=Index+4;
			search_HostIndicator;
			end if;
		else 
			possibleErrorLine:=line_number;
			--Put("missing host");
			errorGroupId := groupId;
			errorFlag := TRUE;
			errorLineNumber:=possibleErrorLine;
			Index:=Index+1;
			
		end if;
	end if;
	end Search_Host;
	
	
	procedure Search_SCorHost is
	Char: Character;
	begin
	 --Put("Search_SCorHost");
	 skip_Spaces;
	 Char:= MY_ARRAY(Index);
	 case Char is
	 	when ';'			=>     --Put("semicln found");
									--New_Line(1);
									if Index+1<array_Size then
										Index:=Index+1;
										search_Host;
									else
										--Put("Parsing Complete");
										parsingComplete := True;
									end if;
		when others			=>     --Put("--------call search host------------");	
									--New_Line(1);
									Search_Host;
	 
	 end case; 
	end Search_SCorHost;
	
	
	
	procedure search_CBorKey is
	possibleErrorLine : Integer;
	Char: Character;
	begin
	--Put("-----------search CB or key-----------");
	--New_Line(1);
	possibleErrorLine:=line_number;
		newLineFound := FALSE;
		skip_Spaces;
		Char:= MY_ARRAY(Index);
		case Char is
		when '}'			=>     --Put("great cb found");
								--New_Line(1);
								groupId := groupId+1;
								if Index+1<array_Size then
								Index:=Index+1;
								search_SCorHost;
								else
									--Put("Parsing Complete");
									parsingComplete := True;
								end if;
		when others			=>     --Put("--------search key------------");	
								--New_Line(1);
								if Token_List(tokenArrayIndex-1).token_Name ="Val" then
									if NewLineFound = TRUE then
									Search_Key;
									else 
									--Put("no new line between value and next key");
									errorLineNumber:=possibleErrorLine;
									errorGroupId := groupId;
									errorFlag := TRUE;
									end if;
								else 
									Search_Key;
								end if;
								
															
		end case;
	
	end search_CBorKey;
				
	procedure Search_OB is
	possibleErrorLine: Integer;
	begin
	-- Put("---------------Search_OB-------------");
	 --New_Line(1);
	 
	 skip_Spaces;
	 
	 if My_Array(Index) = '{' and  Index+1< array_Size then
	 	--Put("OB found in search_OB");
	 	--New_Line(1);
	 	Index:=Index+1;
	 	search_CBorKey;
	 else
	 	--Put("error OB not found");
	 	possibleErrorLine:=line_number;
	 	errorGroupId := groupId;
	 	errorFlag := TRUE;
	 	errorLineNumber:= possibleErrorLine;
	 	--Put("line_number if ob not found is ");
	 	--Put(possibleErrorLine);
	 end if;
	end Search_OB;
				
	procedure search_global is
	begin
		--Put("------Search_global----------");
		--New_Line(1);
		if Index+6< array_Size and My_Array(Index) = 'g'  then
			
			if My_Array(Index) = 'g' 
			and My_Array(Index+1) = 'l'
			and My_Array(Index+2) = 'o'
			and My_Array(Index+3) = 'b'
			and My_Array(Index+4) = 'a'
			and My_Array(Index+5) = 'l'
			 then 
			--Put("global found");
			--New_Line(1);
			Token_List(tokenArrayIndex).token_Name:="Glo";
			Token_List(tokenArrayIndex).tokenGroupId:=groupId;
			tokenArrayIndex:=tokenArrayIndex+1;
			Index:=Index+6;
			search_OB;
			else 
			--Put("incooredr found");
			errorLineNumber:= line_number;
			Index:=Index+1;
			errorGroupId := groupId;
			
			errorFlag:= TRUE;
			end if;
		else 
			--Put("incooredr found");
			errorLineNumber:= line_number;
			Index:=Index+1;
			errorGroupId := groupId;
			errorFlag:= TRUE;
		end if;
	end search_global;
				
	procedure token is
	Char: Character; 
	totalChar : Integer;
	begin
	--Put("<----------This is token------------>");
	--New_Line(1);
	--Put("printing array-inside token");
	--New_Line(1);
	totalChar :=0;
		while Index < array_Size loop 
		--Put("Element Read   ");
		--Put(MY_ARRAY(Index));
		--New_Line(1);			
   		Char:= MY_ARRAY(Index);	
   		skip_Spaces;
   		search_global; 
        totalChar:=totalChar+1;
        	if errorFlag = True 
         		or parsingComplete = TRUE 
         		then
         		exit;
         	end if;	  
         	 
   		end loop;
   		if totalChar<1 then
   		errorFlag:= TRUE;
   		errorLineNumber:= line_number;
   		end if;
	end token;
	
	

	begin
	
	ReadfromFile;		--Check 1,6 ( Confirm If ony tab is also allowed) ,8( cinfirm space after,11,14A(new line, and null) condition
	if fileErrorFlag = False then
	token;
	end if;				
	printarray;
	
end imp3ada;

