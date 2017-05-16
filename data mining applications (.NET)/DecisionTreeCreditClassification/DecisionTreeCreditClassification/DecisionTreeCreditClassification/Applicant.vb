Imports numl.Model
Imports System
Imports System.IO
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Public Class Applicant
    Private _CheckingAccount
    Private _CreditHistory
    Private _Job
    Private _Foreigner
    Private _CreditClass
    Private _PresentEmployment
    Public Enum CreditTypes
        Good = 1
        Bad = 2
    End Enum
    <Feature>
        Public Property CheckingAccount() As String
        Get
            Return _CheckingAccount
        End Get
        Set(ByVal NewValue As String)
            _CheckingAccount = NewValue
        End Set
    End Property
    <Feature>
    Public Property CreditHistory() As String
        Get
            Return _CreditHistory
        End Get
        Set(ByVal NewValue As String)
            _CreditHistory = NewValue
        End Set
    End Property
    <Feature>
    Public Property PresentEmployment() As String
        Get
            Return _PresentEmployment
        End Get
        Set(ByVal NewValue As String)
            _PresentEmployment = NewValue
        End Set
    End Property
    <Feature>
    Public Property Job() As String
        Get
            Return _Job
        End Get
        Set(ByVal NewValue As String)
            _Job = NewValue
        End Set
    End Property
    <Feature>
    Public Property Foreigner() As String
        Get
            Return _Foreigner
        End Get
        Set(ByVal NewValue As String)
            _Foreigner = NewValue
        End Set
    End Property
    <Label> _
    Public Property CreditClass() As CreditTypes
        Get
            Return _CreditClass
        End Get
        Set(ByVal NewValue As CreditTypes)
            _CreditClass = NewValue
        End Set
    End Property
End Class
