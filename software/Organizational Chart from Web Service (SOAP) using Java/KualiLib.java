package edu.uconn.aim;

import java.rmi.RemoteException;
import org.apache.axis2.AxisFault;
import org.apache.axis2.client.Options;
import org.kuali.rice.uconn.v2_0.GetChildOrganizationsByKualiNbrDocument;
import org.kuali.rice.uconn.v2_0.GetChildOrganizationsByKualiNbrResponse;
import org.kuali.rice.uconn.v2_0.GetChildOrganizationsByKualiNbrResponseDocument;
import org.kuali.rice.uconn.v2_0.GetDepartments;
import org.kuali.rice.uconn.v2_0.GetDepartmentsDocument;
import org.kuali.rice.uconn.v2_0.GetDepartmentsResponse;
import org.kuali.rice.uconn.v2_0.GetDepartmentsResponseDocument;
import org.kuali.rice.uconn.v2_0.GetOrgHieracharyDocument;
import org.kuali.rice.uconn.v2_0.GetOrgHieracharyResponse;
import org.kuali.rice.uconn.v2_0.GetOrgHieracharyResponseDocument;
import org.kuali.rice.uconn.v2_0.UConnOrganizationInfo;
import org.kuali.rice.uconn.v2_0.UcMudOrgWsServiceStub;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;


public class KualiLib {
	static String ENDPOINT = "https://xxx/WsService";
	static FileWriter fileWriter;
	static BufferedWriter orgWriter;
	static Connection remoteconn;
	static Connection localconn;
	static UcMudOrgWsServiceStub serviceStub;
	
	static UConnOrganizationInfo GetParentFromChildHelper(UConnOrganizationInfo node, int depth, String code) {
		GetChildOrganizationsByKualiNbrResponse response = null;
		UConnOrganizationInfo result_node = null;
		try {
			serviceStub = new UcMudOrgWsServiceStub(ENDPOINT);
			Options option = serviceStub._getServiceClient().getOptions();
			option.setProperty(org.apache.axis2.Constants.Configuration.DISABLE_SOAP_ACTION, true);
			
			GetChildOrganizationsByKualiNbrDocument doc = GetChildOrganizationsByKualiNbrDocument.Factory.newInstance();
			doc.addNewGetChildOrganizationsByKualiNbr().setKualiOrgCd(node.getKualiOrgCd());
			
			GetChildOrganizationsByKualiNbrResponseDocument responseDoc = serviceStub.getChildOrganizationsByKualiNbr(doc);
			response = responseDoc.getGetChildOrganizationsByKualiNbrResponse();
			
			UConnOrganizationInfo[] adjacentList = response.getReturnArray();
			Arrays.sort(adjacentList, new Comparator<UConnOrganizationInfo>() {
			    @Override
			    public int compare(UConnOrganizationInfo node1, UConnOrganizationInfo node2) {
			        return node1.getKualiOrgCd().compareTo(node2.getKualiOrgCd());
			    }
			});
			
			for (UConnOrganizationInfo child:adjacentList) {
				//System.out.println("At node " + child.getKualiOrgCd());
				if (child.getKualiOrgCd().equals(code) && (!child.getKualiOrgCd().equals("0000"))) {
					//System.out.println("Found parent of " + code);
					result_node = node;
					break;
				}
				
				if (result_node == null && !node.getKualiOrgCd().equals(child.getKualiOrgCd()) && (!child.getKualiOrgCd().equals("0000"))) {
					//System.out.println(child.getKualiOrgCd());
					result_node = GetParentFromChildHelper(child, depth + 1, code);
					//if (result_node != null) System.out.println(result_node.toString());
				}				
			}
		} 
		catch (AxisFault e) {
			e.printStackTrace();
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return result_node;
	}
	
	static String GetParentFromChild(String code) {
		GetOrgHieracharyResponse response = null;
		UConnOrganizationInfo result_node = null;
		try {
			UcMudOrgWsServiceStub serviceStub = new UcMudOrgWsServiceStub(ENDPOINT);
			Options option = serviceStub._getServiceClient().getOptions();
			option.setProperty(org.apache.axis2.Constants.Configuration.DISABLE_SOAP_ACTION, true);
			
			GetOrgHieracharyDocument doc = GetOrgHieracharyDocument.Factory.newInstance();
			doc.addNewGetOrgHierachary().setDeptNo("0000");
			
			GetOrgHieracharyResponseDocument responseDoc = serviceStub.getOrgHierachary(doc);
			response = responseDoc.getGetOrgHieracharyResponse(); // return a node
			UConnOrganizationInfo node = response.getReturnArray()[0]; 
			result_node =  GetParentFromChildHelper(node, 0, code);
		}
		catch (AxisFault e) {
			e.printStackTrace();
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return (result_node != null)?result_node.getKualiOrgCd() : null;
	}
	
	static UConnOrganizationInfo[] GetChildTest(String code) {
		GetChildOrganizationsByKualiNbrResponse response = null;
		UcMudOrgWsServiceStub serviceStub;
		UConnOrganizationInfo[] adjacentList = null;
		try {
			serviceStub = new UcMudOrgWsServiceStub(ENDPOINT);
			Options option = serviceStub._getServiceClient().getOptions();
			option.setProperty(org.apache.axis2.Constants.Configuration.DISABLE_SOAP_ACTION, true);
			
			GetChildOrganizationsByKualiNbrDocument doc = GetChildOrganizationsByKualiNbrDocument.Factory.newInstance();
			doc.addNewGetChildOrganizationsByKualiNbr().setKualiOrgCd(code);
			
			GetChildOrganizationsByKualiNbrResponseDocument responseDoc = serviceStub.getChildOrganizationsByKualiNbr(doc);
			response = responseDoc.getGetChildOrganizationsByKualiNbrResponse();
			
			adjacentList = response.getReturnArray();
			
			for (UConnOrganizationInfo child:adjacentList) {
				System.out.println("At node " + child.getKualiOrgCd());
			}
		} 
		catch (AxisFault e) {
			e.printStackTrace();
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}		
		return adjacentList;
	}
	
	/*
	 3 following methods generateOrgTree, generateOrgTreeHelper, and TabNum are to generate the organization chart in a text file 
	*/
	
	static String TabNum(int depth) {
		return new String(new char[depth]).replace("\0", "\t");
	}
	
	static void generateOrgTreeHelper(UConnOrganizationInfo node, int depth) {
		GetChildOrganizationsByKualiNbrResponse response = null;
		try {
			serviceStub = new UcMudOrgWsServiceStub(ENDPOINT);
			Options option = serviceStub._getServiceClient().getOptions();
			option.setProperty(org.apache.axis2.Constants.Configuration.DISABLE_SOAP_ACTION, true);
			
			GetChildOrganizationsByKualiNbrDocument doc = GetChildOrganizationsByKualiNbrDocument.Factory.newInstance();
			doc.addNewGetChildOrganizationsByKualiNbr().setKualiOrgCd(node.getKualiOrgCd());
			
			GetChildOrganizationsByKualiNbrResponseDocument responseDoc = serviceStub.getChildOrganizationsByKualiNbr(doc);
			orgWriter.write(node.getName() + "\t" + node.getKualiOrgCd() + "\t" + depth + "\n");
			response = responseDoc.getGetChildOrganizationsByKualiNbrResponse();
			
			UConnOrganizationInfo[] adjacentList = response.getReturnArray();
			Arrays.sort(adjacentList, new Comparator<UConnOrganizationInfo>() {
			    @Override
			    public int compare(UConnOrganizationInfo node1, UConnOrganizationInfo node2) {
			        return node1.getKualiOrgCd().compareTo(node2.getKualiOrgCd());
			    }
			}); 
					
			if (adjacentList.length == 0) {
				return;
			}
			
			for (UConnOrganizationInfo child:adjacentList) {
				if (!node.getKualiOrgCd().equals(child.getKualiOrgCd()) && (!child.getKualiOrgCd().equals("0000"))) {
					generateOrgTreeHelper(child, depth + 1);		
				}
			}
		} 
		catch (AxisFault e) {
			e.printStackTrace();
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	static GetChildOrganizationsByKualiNbrResponse generateOrgTree(String dirFile) {
		GetOrgHieracharyResponse response = null;
		try {
			fileWriter = new FileWriter(System.getProperty("user.home") + dirFile,false);
	        orgWriter = new BufferedWriter(fileWriter);
	        
			UcMudOrgWsServiceStub serviceStub = new UcMudOrgWsServiceStub(ENDPOINT);
			Options option = serviceStub._getServiceClient().getOptions();
			option.setProperty(org.apache.axis2.Constants.Configuration.DISABLE_SOAP_ACTION, true);
			
			GetOrgHieracharyDocument doc = GetOrgHieracharyDocument.Factory.newInstance();
			doc.addNewGetOrgHierachary().setDeptNo("0000");
			
			GetOrgHieracharyResponseDocument responseDoc = serviceStub.getOrgHierachary(doc);
			response = responseDoc.getGetOrgHieracharyResponse(); // return a node
			UConnOrganizationInfo node = response.getReturnArray()[0]; 
			generateOrgTreeHelper(node, 0);
		}
		catch (AxisFault e) {
			e.printStackTrace();
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				if (orgWriter != null) orgWriter.close();
				if (fileWriter != null) fileWriter.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		return null;
	}
	
}


import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.rmi.RemoteException;
import java.util.Arrays;
import java.util.Comparator;


import org.apache.axis2.AxisFault;
import org.apache.axis2.client.Options;
import org.apache.axis2.transport.http.HttpTransportProperties;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

public class WebService {
	public static void main(String[] args) {
		Logger.getRootLogger().setLevel(Level.OFF);
		KualiLib.generateOrgTree("\\Documents\\nodelist.txt");
	}
}

