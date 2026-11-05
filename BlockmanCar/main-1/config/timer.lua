-- ========================================
-- File: timer.lua
-- Created: 2026-11-04 23:15
-- Author: Saurav
-- ========================================

timer = {}

local CGameTimeTask = class("GameTimeTask", ITask)
function CGameTimeTask:onTick(ticks)
    timer:onTick(ticks)
end

function timer:init()
	self._gid = 0			-- id ������
	self._current = 0		-- ��ǰʱ��
	self._timer = {}		-- [id] = ʱ��
	self._schedule = {}		-- [ʱ��][id] = �ص�
	self._work = 0
	self._closing = {}

    self._drive = CGameTimeTask.new()
    self._drive:start()
end

function timer:onTick()
	self._current = self._current + 1
	self._work = 1
	assert(self._current > 0)
	local schedule = self._schedule[self._current]
	if (schedule) then
		for id, timer in pairs(schedule) do
			local ret = timer[2](unpack(timer, 3))
			if (not ret) then
				ret = timer[1]	-- �ص��޷���ֵ��ʾͬƵ�ʼ���ִ��
			end
			assert(type(ret) == "number")
			if (ret > 0) then	-- �ص�����ֵ��ʾ�೤ʱ����ٴ�ִ��
				local time = math.ceil(ret)
				local t_time = time + self._current
				self._timer[id] = t_time
				self._schedule[t_time] = self._schedule[t_time] or {}
				self._schedule[t_time][id] = {time, unpack(timer, 2)}
			else
				self:close(id)
			end
		end
	end
	self._schedule[self._current] = nil
	self._work = 0

	for _, id in ipairs(self._closing) do
		self:close(id)
	end

	self._closing = {}
end

-- time ��λ��֡, fun����<=0��ʾ�ر�timer��nil��ʾ�ϴζ�ʱ��ʱ�䣬> 0 ��ʾ�����ô���
function timer:register(time, fun, ...)
	assert(time > 0)
	local t_time = math.ceil(time) + self._current
	self._gid = self._gid + 1
	self._timer[self._gid] = t_time
	self._schedule[t_time] = self._schedule[t_time] or {}
	self._schedule[t_time][self._gid] = {time, fun, ...}
	return self._gid
end

function timer:modify(id, time)
	assert(time > 0)
	assert(self._work == 0)

	if (not self._timer[id]) then
		return false
	end

	time = math.ceil(time)
	local o_time = self._timer[id]
	local t_time = time + self._current
	self._timer[id] = t_time
	self._schedule[t_time] = self._schedule[t_time] or {}
	self._schedule[t_time][id] = self._schedule[o_time][id]	-- ע�⣬����[1]δ�䣬����ص�����nil���ᰴ�ϵ�Ƶ�ʵ���
	
	self._schedule[o_time][id] = nil
end

function timer:remain(id)
	if (not self._timer[id]) then
		return math.maxinteger
	end

	for _, cid in ipairs(self._closing) do
		if (cid == id) then
			return math.maxinteger
		end
	end

	return self._timer[id] - self._current
end

function timer:totle(id)
	local t_time = self._timer[id]
	if (not t_time) then
		return math.maxinteger
	end
	
	return self._schedule[t_time][id][1]
end

function timer:close(id)
	if (not id) then
		return
	end
	if (self._work ~= 0) then
		table.insert(self._closing, id)
		return
	end

	local time = self._timer[id]
	if (time) then -- nil ��ʾ�Ѿ�ɾ��
		self._timer[id] = nil
		if (self._schedule[time]) then
			self._schedule[time][id] = nil
		end
	end
end

return timer
