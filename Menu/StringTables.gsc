GobblegumName(name)
{
    return TableLookupIString("gamedata/stats/zm/zm_statstable.csv", 4, name, 3);
}