import networkx as nx
import matplotlib.pyplot as plt
import pydotplus 
from suds.client import Client

def traverseTree(node, depth = 0):
    G.add_node(node[0]['kualiOrgCd'])
    adjacentList = client.service.getChildOrganizationsByKualiNbr(kualiOrgCd = node[0]['kualiOrgCd'])
    sorted(adjacentList, key = lambda child: child['kualiOrgCd'])
    writeNode(tabNum(depth) + node[0]['name'] + "(" + node[0]['kualiOrgCd'] + ")\n")
    # print(node[0]['kualiOrgCd'] + "," + node[0]['headNetId'])
    # reach the lowest depth
    #if (len(adjacentList) == 0  or depth>=4):
    if (len(adjacentList) == 0):        
        return
        
    for child in adjacentList:
        if node[0]['kualiOrgCd'] != child['kualiOrgCd']: # to prevent the case a node reports to itself and repeats forever
            G.add_node(child['kualiOrgCd'])
            G.add_edge(node[0]['kualiOrgCd'],child['kualiOrgCd'])
            traverseTree(node = [child], depth = depth + 1)

def writeNode(text):
    file.write(text)  

def tabNum(depth):
    tabs = ""
    for i in range(depth):
        tabs = tabs + "\t"
    return tabs           

folder = "xxx"
file = open(folder + "org_chart.txt","w")     
url="xxx?wsdl"
client=Client(url)

node = client.service.getOrgHierachary(deptNo = "0000")
G = nx.DiGraph()
traverseTree(node)
file.close()

# write dot file to use with graphviz
# run "dot -Tpng test.dot >test.png"
nx.write_dot(G,folder + "org_chart.dot")
# Run this: dot -Tpdf org_chart.dot -o org_chart.pdf

# or can generate PDF in Python directly
dotFile = open(folder + "org_chart.dot", "r")
dotData=dotFile.read()
graph = pydotplus.graph_from_dot_data(dotData) 
graph.write_pdf(folder + "org_chart.pdf") 
