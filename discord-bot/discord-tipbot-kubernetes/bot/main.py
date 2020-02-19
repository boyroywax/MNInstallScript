import asyncio
import botconf as b
import discord
from discord.ext import commands
import redis_cmd
import logging
import time
import sys

# create redis object
rc = redis_cmd.Redis()

# create discord bot object
bot = commands.Bot(command_prefix=b.pre)

# Boiler Plate code which creates a log file instead of printing to console 
# https://discordpy.readthedocs.io/en/latest/logging.html
###
root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
# formatter = logging.FileHandler(filename='discord.log', encoding='utf-8', mode='w')
formatter = logging.Formatter('%(asctime)s:%(levelname)s:%(name)s: %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)
logger = root

@bot.event
async def on_ready():
    if hasattr(bot, 'initialised'):
        return    # Prevents mutiple on ready call

    bot.initialised = True
    logger.info('The Bot is now ready')


@bot.command(pass_context=True)
async def hello(ctx):
    """say hello"""
    server = ctx.message.server
    if server is None:
        await bot.send_message(ctx.message.channel, 'hello this is direct message')
    else:
        await bot.send_message(ctx.message.channel, 'hello this is public message')

@bot.command(pass_context=True)
async def hits(ctx):
    """get the number of intercepted messages"""
    count = await rc.getValue('hits')
    try:
        await bot.send_message(ctx.message.channel, 'Number of hits is {}'.format(int(count)))
    except:
        logger.error('Could not send $hits response.')

@bot.command(pass_context=True)
async def lastMsg(ctx):
    """get your last msg time"""
    sender_id = "user:" + str(ctx.message.author.id)
    userDict = await rc.getHash(sender_id, "last_msg")
    try:
        await bot.send_message(ctx.message.channel, 'Last Message: {}'.format(userDict))
    except:
        logger.error('Could not send $lastMsg response.')

@bot.command(pass_context=True)
async def isAdmin(ctx):
    sender_id = "user:" + str(ctx.message.author.id)
    userDict = await rc.getHash(sender_id, "adminStatus")
    try:
        await bot.send_message(ctx.message.channel, 'Admin Status: {}'.format(userDict))
    except:
        logger.error('Could not send $isAdmin response.')

@bot.command(pass_context=True)
async def register(ctx):
    sender_id = "user:" + str(ctx.message.author.id)
    registerResponse = await rc.setHash(sender_id, "registered", "True")
    try:
        await bot.send_message(ctx.message.channel, 'User Register Response: {}'.format(registerResponse))
    except:
        logger.error('Could not send $register response.')

@bot.command(pass_context=True)
async def showKeys(ctx):
    getKeys = await rc.hashScan()
    await bot.send_message(ctx.message.channel, 'User in registry - {}'.format(', '.join(getKeys)))
    

@bot.event
async def on_message(msg):
    # extract the message content
    cmd = msg.content
    # extract the channel the message originated from
    chan = msg.channel

    # check if the channel is private
    is_private = False
    if chan.is_private:
        is_private is True
    
    # extract the message author, username, and userid
    a = msg.author
    uname = a.name
    discord_user = str(a.id)

    # Check if the message is from a bot (including this bot)
    if a.bot:
        return

    # check if the message content is a command
    iscommand = cmd.startswith(b.pre)

    # log the command
    if iscommand:
        cmd = cmd[1:]
        log_msg = 'COMMAND "%s" executed by %s (%s)'
        if is_private:
            log_msg = log_msg + ' in private channel'
        logger.info(log_msg, cmd.split()[0], discord_user, uname)

    # increment the redis hit counter
    incValue = await rc.incValue('hits')
    if incValue is True:
        logger.info('The Bot has interecpted a message and registered a hit')
    else:
        logger.error('The bot intercepted a message but could not register a hit')

  
    # format time string
    hashName = "user:" + discord_user
    currentTime = str(time.time())

    # check if the user is admin
    adminStatusVal = "False"
    if discord_user == b.bot_owner: 
        adminStatusVal = "True"

    #check if the user is registered with the service
    registerStatus = "False"
    userExists = await rc.getHash(hashName, "registered")
    if userExists == "True":
        # await bot.send_message(chan, 'You are already registered')
        registerStatus = "True"
    else:
        registerStatus = "False"
        await bot.send_message(chan, 'Hello {}! Would you like to REGISTER? Type {}'.format(uname, b.register_command))
    
    createdHashMap = {"user_id": discord_user, "adminStatus": adminStatusVal, "last_msg": currentTime, "registered": registerStatus}

    # create a last_msg field and adminStatus field in hashmap
    # add user hashmap
    hashResponse = await rc.setHashMaps(hashName, createdHashMap)
    logger.info('hashResponse - {}'.format(hashResponse))


    # pass commands to functions
    await bot.process_commands(msg)

# start the async discord bot
bot.run(b.discord_token)