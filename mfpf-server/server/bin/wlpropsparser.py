def prepareConfigDropinsXml(properties):
    str = properties.split(',')
    propsDictionary = { }
    for element in str:
        index = element.find(':')
        if ( index != -1 ):
            key = element[:index]
            value=element[index+1:]
            propsDictionary[key]=value
    result = list()
    result.append("<server description=\"new server\">")
    result.extend(dictionaryToXml(propsDictionary))
    result.append("</server>")
    return "\n".join(result)

def dictionaryToXml(properties):
    jndiElements = list();
    for prop in properties:
        propValue = properties[prop]
        jndiElements.append("<jndiEntry jndiName=\"%s\" value=\"%s\"/>" % (prop, propValue))
    return jndiElements

import sys
print(prepareConfigDropinsXml(sys.argv[1]))