import math
import discord
from discord.ext import commands
from utils import rpc_module, mysql_module, checks, parsing
import random

rpc = rpc_module.Rpc()
mysql = mysql_module.Mysql()


class Soak:
    def __init__(self, bot):
        self.bot = bot
        soak_config = parsing.parse_json('config.json')['soak']
        '''
        soak_max_recipients sets the max recipients for a soak. chosen randomly.
        soak_min_received sets the minimum possible soak received for a user.
        The number of soak recipients will be adjusted to fit these constraints
        if enabled via use_max_recipients and use_min_received
        '''
        self.soak_max_recipients = soak_config["soak_max_recipients"]
        self.use_max_recipients = soak_config["use_max_recipients"]
        self.soak_min_received = soak_config["soak_min_received"]
        self.use_min_received = soak_config["use_min_received"]        

    @commands.command(pass_context=True)
    @commands.check(checks.allow_soak)
    async def soak(self, ctx, amount: float):
        """Tip all online users"""
        if self.use_max_recipients and self.soak_max_recipients == 0:
            await self.bot.say("**:warning: Max users for soak is set to 0! Talk to the config owner. :warning:**")
            return

        snowflake = ctx.message.author.id

        mysql.check_for_user(snowflake)
        balance = mysql.get_balance(snowflake, check_update=True)

        if float(balance) < amount:
            await self.bot.say("{} **:warning: You cannot soak more money than you have! :warning:**".format(ctx.message.author.mention))
            return

        online_users = [x for x in ctx.message.server.members if x.status == discord.Status.online]
        if ctx.message.author in online_users:
            online_users.remove(ctx.message.author)

        for user in online_users:
            if user.bot:
                online_users.remove(user)

        if self.use_max_recipients:
            len_receivers = min(len(online_users), self.soak_max_recipients)
        else:
            len_receivers = len(online_users)

        if self.use_min_received:
            if amount < self.soak_min_received:
                await self.bot.say("{}, **:warning: {} is less than the minimum amount ({})  allowed to be soaked! :warning:**".format(ctx.message.author.mention, amount, self.soak_min_received))
                return
            len_receivers = min(len_receivers, amount / self.soak_min_received)

        if len_receivers == 0:
            await self.bot.say("{}, **:warning:  you are all alone if you don't include bots! Try soaking when people are online. :warning:**".format(ctx.message.author.mention))
            return

        amount_split = math.floor(float(amount) * 1e8 / len_receivers) / 1e8
        if amount_split == 0:
            await self.bot.say("{} **:warning: {} BOXY is not enough to split between {} users! :warning:**".format(ctx.message.author.mention, amount, len_receivers))
            return
        receivers = []
        for i in range(int(len_receivers)):
            user = random.choice(online_users)
            receivers.append(user)
            online_users.remove(user)
            mysql.check_for_user(user.id)
            mysql.add_tip(snowflake, user.id, amount_split)
        long_soak_msg = ":cloud_rain: {} **Soaked {} BOXY on {} users [Total {} BOXY]** :cloud_rain: \n".format(ctx.message.author.mention, str(amount_split), len_receivers , str(amount))

        #bot response:
        await self.bot.say(long_soak_msg)

        #parse into 25 username sized message chunks
        users_soaked_msg = []
        for users in receivers:
            users_soaked_msg.append(users.mention)
            if (len(users_soaked_msg) >= 25) or (users == int(len_receivers)):
                await self.bot.say("{}".format(' '.join(users_soaked_msg)))
                del users_soaked_msg[:]
                users_soaked_msg = []


    @commands.command()
    async def soak_info(self):
        """Display min soak amount and maximum soak recipients"""
        if self.use_max_recipients:
            st_max_users = str(self.soak_max_recipients)
        else:
            st_max_users = "<disabled>"

        if self.use_min_received:
            st_min_received = str(self.soak_min_received)
        else:
            st_min_received = "<disabled>"
            
        await self.bot.say(":information_source: Soak info: max recipients {}, min amount receivable {} :information_source:".format(st_max_users, st_min_received))

def setup(bot):
    bot.add_cog(Soak(bot))
