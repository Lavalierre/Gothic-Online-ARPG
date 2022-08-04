local function clamp(value, min, max)
{
	if (value < min)
		return min

	if (value > max)
		return max

	return value
}

/////////////////////////////////////////
///	Player list class
/////////////////////////////////////////

PlayerList <- {
	// Private
	_hostname = null,
	_headers = [],
	_rows = array(getMaxSlots(), null),
	_backgrounds = [],
	_lineHeightPx = -1,
	
	// Public
	visible = false,
	x = -1,
	y = 100,
	width = -1,
	height = -1,

	// Read only
	begin = 0,
	size = 0,

	// Constans
	MAX_VISIBLE_ROWS = 30

	COLUMN_ID = -1,
	COLUMN_NICKNAME = -1,
	COLUMN_PING = -1,
}

function PlayerList::init()
{
	// List draw
	_hostname = Draw(0, 0, getHostname())
	_hostname.font = "FONT_OLD_20_WHITE_HI.TGA"
	_hostname.setPositionPx(nax(4096 - _hostname.width / 2), y / 2)

	// Add columns after this line....
	COLUMN_ID = registerColumn("Id", 200)
	COLUMN_NICKNAME = registerColumn("Nickname", 3000)
	COLUMN_PING = registerColumn("Ping", 100)

	// Add textures after this line...
	registerTexture("MENU_INGAME.TGA", function ()
	{
		tex.setPositionPx(PlayerList.x - 25,PlayerList.y - 15)
		tex.setSizePx(PlayerList.width + 50, PlayerList.height + 30)
	})

	// Setup row line height in pixels
	_lineHeightPx = _headers.top().draw.heightPx

	// Update UI size
	resize()
}

function PlayerList::registerColumn(name, width)
{
	local draw = Draw(0, 0, name)
	draw.setColor(255, 255, 0)

	_headers.push({
		name = name,
		width = width,
		draw = draw,
	})

	return _headers.len() - 1
}

function PlayerList::registerTexture(name, resize)
{
	local tex = Texture(0, 0, 0, 0, name)
	local bg = {
		resize = resize,
		tex = tex,
	}

	_backgrounds.push(bg)
}

function PlayerList::getRow(pid)
{
	return _rows[pid]
}

function PlayerList::setVisible(visible)
{
	this.visible = visible
	_hostname.visible = visible

	foreach (bg in _backgrounds)
		bg.tex.visible = visible

	foreach (header in _headers)
		header.draw.visible = visible

	_showRows()
}

function PlayerList::refresh(value)
{
	_hideRows()

	local len = size - MAX_VISIBLE_ROWS + 1
	if (len < 0) len = 0

	begin = clamp(value, 0, len)

	_showRows()
}

function PlayerList::insert(pid)
{
	if (pid >= _rows.len())
		return

	local playerRow = heroId != pid ? PlayerListRow(255, 255, 255) : PlayerListRow(255, 150, 0)
	
	_rows[pid] = playerRow
	++size
	
	local isInView = _isInView(playerRow)
	
	if (visible && isInView)
	{
		_rows[pid] = null
		_hideRows()
	}

	local len = size - MAX_VISIBLE_ROWS + 1
	if (len < 0) len = 0

	begin = clamp(begin, 0, len)

	if (visible && isInView)
	{
		_rows[pid] = playerRow
		_showRows()
	}

	return playerRow
}

function PlayerList::remove(pid)
{
	if (pid >= _rows.len())
		return
	
	// refresh is only required when all lines must be updated
	local wasInView = (begin != 0) ? _isInView(_rows[pid]) : false

	if (visible && wasInView)
		_hideRows()

	_rows[pid] = null
	--size

	local len = size - MAX_VISIBLE_ROWS + 1
	if (len < 0) len = 0

	begin = clamp(begin, 0, len)

	if (visible && wasInView)
		_showRows()
}

function PlayerList::resize()
{
	width = 0
	height = _lineHeightPx * MAX_VISIBLE_ROWS

	foreach (header in _headers)
		width += (nax(header.width) + header.draw.widthPx)

	local headerX = x = (getResolution().x - width) / 2
	local headerY = y

	width = 0
	foreach (header in _headers)
	{
		header.draw.setPositionPx(headerX + width, headerY)
		width += (nax(header.width) + header.draw.widthPx)
	}
	
	local offset = _lineHeightPx
	_foreachVisibleRow(function(idx, row)
	{
		row.setPositionPx(x, y + offset)
		offset += row.heightPx()
	})

	foreach (bg in _backgrounds)
		bg.resize()
}

function PlayerList::_foreachVisibleRow(callback)
{
	local count = 0

	for (local i = begin, rowsLen = _rows.len(); i < rowsLen && count < MAX_VISIBLE_ROWS - 1; ++i)
	{
		local item = _rows[i]

		if (!item)
			continue
			
		if (callback(i, item))
			break

		++count
	}
}

function PlayerList::_isInView(playerRow)
{
	local isInView = false

	_foreachVisibleRow(function(idx, row)
	{
		if (row == playerRow)
		{
			isInView = true
			return true
		}
	})

	return isInView
}

function PlayerList::_hideRows()
{
	_foreachVisibleRow(function(idx, row)
	{
		row.setVisible(false)
	})
}

function PlayerList::_showRows()
{
	local offset = _lineHeightPx
	_foreachVisibleRow(function(idx, row)
	{
		row.setPositionPx(x, y + offset)
		offset += row.heightPx()

		row.setVisible(visible)
	})
}

/////////////////////////////////////////
///	Player list row class
/////////////////////////////////////////

class PlayerListRow
{
	constructor(r, g, b)
	{
		columns = []
		visible = false

		foreach (header in PlayerList._headers)
		{
			local draw = Draw(0, 0, "")
			draw.setColor(r, g, b)

			columns.push(draw)
		}
	}

	function setVisible(visible)
	{
		this.visible = visible
	
		foreach (column in columns)
			column.visible = visible
	}

	function heightPx()
	{
		return columns.top().heightPx
	}

	function setPositionPx(x, y)
	{
		local headers = PlayerList._headers
		local width = 0

		foreach (id, column in columns)
		{
			column.setPositionPx(x + width, y)
			width += (nax(headers[id].width) + headers[id].draw.widthPx)
		}
	}

	columns = null
	visible = false
}

/////////////////////////////////////////
///	Events
/////////////////////////////////////////

addEventHandler("onPlayerCreate", function(pid)
{
	local playerRow = PlayerList.insert(pid)

	// Init item with default data
	local color = getPlayerColor(pid)

	playerRow.columns[PlayerList.COLUMN_ID].text = pid
	playerRow.columns[PlayerList.COLUMN_NICKNAME].text = getPlayerName(pid)
	playerRow.columns[PlayerList.COLUMN_NICKNAME].setColor(color.r, color.g, color.b)
	playerRow.columns[PlayerList.COLUMN_PING].text = getPlayerPing(pid)
})

addEventHandler("onPlayerDestroy", function(pid)
{
	PlayerList.remove(pid)
})

addEventHandler("onPlayerChangePing", function(pid, ping)
{
	local playerRow = PlayerList.getRow(pid)

	if (playerRow)
		playerRow.columns[PlayerList.COLUMN_PING].text = ping
})

addEventHandler("onPlayerChangeNickname", function(pid, name)
{
	local playerRow = PlayerList.getRow(pid)

	if (playerRow)
		playerRow.columns[PlayerList.COLUMN_NICKNAME].text = name
})

addEventHandler("onPlayerChangeColor", function(pid, r, g, b)
{
	local playerRow = PlayerList.getRow(pid)

	if (playerRow)
		playerRow.columns[PlayerList.COLUMN_NICKNAME].setColor(r, g, b)
})

addEventHandler("onKey", function(key)
{
	switch (key)
	{
		case KEY_F5:
			if (!chatInputIsOpen())
				PlayerList.setVisible(!PlayerList.visible)
			break

		case KEY_UP:
			if (PlayerList.visible)
				PlayerList.refresh(PlayerList.begin - 1)
			break

		case KEY_DOWN:
			if (PlayerList.visible)
				PlayerList.refresh(PlayerList.begin + 1)
			break

		case KEY_PRIOR:
			if (PlayerList.visible)
				PlayerList.refresh(0)
			break

		case KEY_NEXT:
			if (PlayerList.visible)
				PlayerList.refresh(PlayerList.size - PlayerList.MAX_VISIBLE_ROWS + 1)
			break
	}
})

addEventHandler("onMouseWheel", function(value)
{
	if (PlayerList.visible)
		PlayerList.refresh(PlayerList.begin - value)
})

addEventHandler("onChangeResolution", function()
{
	PlayerList.resize()
})

// Initialize PlayerList
PlayerList.init()

// Loaded
print("playerlist.nut loaded...")