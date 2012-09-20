macro Config()
{
	szUser = Ask("what's your name:")
	SetReg(MYNAME, szUser)
}

macro MakeFileHeader()
{
	szUser = GetReg(MYNAME)
	
	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")
	
	InsBufLine(hbuf, 1, "\t")
	/* if owner variable exists, insert Author: name */
	if (strlen(szUser) > 0)
	{
		sz = "\tAuthor: @szUser@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
	}
	else
		ln = 2
	/* insert $date */
	szDate = Date()
	InsBufLine(hbuf, ln, "\tDate: @szDate@")
	ln = ln + 1
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
	/* put the insertion point */
	SetBufIns(hbuf, 1, 8)
}

macro MakeFuncHeader()
{
	// Get a handle to the current file buffer
	hbuf = GetCurrentBuf()
	szFunc = Ask("function name:")
	if (strlen(szFunc) == 0)
		stop
	szRetType = Ask("return type:")
	if (strlen(szRetType) == 0)
		szRetType = "void"
	//MACRO 2??¡ì3?¨ºy¡Á¨¦¡ê??1¨®D?¨¹?¨°¦Ì£¤¦Ì?¡¤?¡¤¡§?e?
	var param1
	var param2
	var param3
	var param4
	var param5
	cparams = 0
	while (TRUE)
	{
		if (cparams > MAX_FUNC_PARAMS)
		{
			Msg("Too much params, at most 5!")
			stop
		}
		number = cparams + 1
		szType = Ask("@number@ param type")
		if (szType == 0)
			break
		szName = Ask("@number@ param name")
		if (szName == 0)
			break
		if (cparams == 0)
		{
			param1.type = szType
			param1.name = szName
		}
		if (cparams == 1)
		{
			param2.type = szType
			param2.name = szName
		}
		if (cparams == 2)
		{
			param3.type = szType
			param3.name = szName
		}
		if (cparams == 3)
		{
			param4.type = szType
			param4.name = szName
		}
		if (cparams == 4)
		{
			param5.type = szType
			param5.name = szName
		}
		cparams = cparams + 1
	}
	if (cparams == 0)
		szparams = "(void)"
	iparam = 0
	while (iparam < cparams)
	{
		if (iparam == 0)
		{
			szType = param1.type
			szName = param1.name
			szparams = "(@szType@ @szName@"
			iparam = iparam + 1
			continue
		}
		if (iparam == 1)
		{
			szType = param2.type
			szName = param2.name
		}
		if (iparam == 2)
		{
			szType = param3.type
			szName = param3.name
		}
		if (iparam == 3)
		{
			szType = param4.type
			szName = param4.name
		}
		if (iparam == 4)
		{
			szType = param5.type
			szName = param5.name
		}
		szparams = cat(szparams, ", @szType@ @szName@")
		iparam = iparam + 1
	}
	szparams = cat(szparams, ")")
	szFuncHeader = cat(szRetType, " @szFunc@")
	szFuncLine = cat(szFuncHeader, szparams)
	 
	szDate = Date()
	szUser = GetReg(MYNAME)
	ln = GetBufLnCur(hbuf)
	InsBufLine(hbuf, ln, "/*-------------------------------------------------------------------------")
	ln = ln + 1
	InsBufLine(hbuf, ln, "\t@szFunc@")
	InsBufLine(hbuf, ln+1, " ")
	InsBufLine(hbuf, ln+2, " ")
	InsBufLine(hbuf, ln+3, " ")
	desc_ln = ln + 2
	ln = ln + 4
	iparam = 0
	while (iparam < cparams)
	{
		if (iparam == 0)
		{
			szName = param1.name
		}
		if (iparam == 1)
		{
			szName = param2.name
		}
		if (iparam == 2)
		{
			szName = param3.name
		}
		if (iparam == 3)
		{
			szName = param4.name
		}
		if (iparam == 4)
		{
			szName = param5.name
		}
		szParamLine = "\t\@param @szName@: "
		InsBufLine(hbuf, ln, szParamLine)
		ln = ln + 1
		iparam = iparam + 1
	}
	InsBufLine(hbuf, ln, " ")
	ln = ln + 1
	if (strlen(szUser) > 0)
		szDate = cat(szDate, "\tcreated by @szUser@")
	InsBufLine(hbuf, ln, "\t@szDate@")
	ln = ln + 1
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
	ln = ln + 1
	InsBufLine(hbuf, ln, szFuncLine)
	InsBufLine(hbuf, ln+1, "{")
	InsBufLine(hbuf, ln+2, "\t")
	InsBufLine(hbuf, ln+3, "}")
	SetBufIns(hbuf, desc_ln, 0)
}
 
 
 
 


macro Date()
{
	szDate = GetSysTime(TRUE)
	szYear = szDate.Year
	szMonth = szDate.Month
	szDay = szDate.Day
	szHour = szDate.Hour
	szMinute = szDate.Minute
	szSecond = szDate.Second
	if (szMonth < 10)
		szMonth = cat("0", szMonth)
	if (szDay < 10)
		szDay = cat("0", szDay)
	if (szHour < 10)
		szHour = cat("0", szHour)
	if (szMinute < 10)
		szMinute = cat("0", szMinute)
	if (szSecond < 10)
		szSecond = cat("0", szSecond)
	
	szTime = "@szYear@-@szMonth@-@szDay@ @szHour@:@szMinute@:@szSecond@"
	return szTime
}

event AppStart()
{
	/* keep at most 25 open windows */
	global MAX_OPEN_WNDS
	MAX_OPEN_WNDS = 25

	szUser = GetReg(MYNAME)
	if (strlen(szUser) == 0)
	{
		Config()
	}
}

macro CloseOldestWnds(cwnd)
{	
	iwnd = cwnd - 1
	while (iwnd >= MAX_OPEN_WNDS)
	{
		hwnd = WndListItem(iwnd)
		CloseWnd(hwnd)
		iwnd = iwnd - 1
	}
}

event DocumentNew(sFile)
{
	if (MAX_OPEN_WNDS == Nil)
		stop

	cwnd = WndListCount()
	if (cwnd > MAX_OPEN_WNDS)
	{
		CloseOldestWnds(cwnd)
	}
	MakeFileHeader()
}
 
event DocumentOpen(sFile)
{
	if (MAX_OPEN_WNDS == Nil)
		stop
		
	cwnd = WndListCount()
	if (cwnd > MAX_OPEN_WNDS)
	{
		CloseOldestWnds(cwnd)
	}
}


