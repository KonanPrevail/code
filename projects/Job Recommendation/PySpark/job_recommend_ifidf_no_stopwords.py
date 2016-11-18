from pyspark.ml.feature import HashingTF, IDF, Tokenizer,StopWordsRemover
from pyspark.ml.feature import HashingTF, IDF, Tokenizer
from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.classification import NaiveBayes   
from pyspark.sql import SQLContext, Row
import re

sqlContext = SQLContext(sc)

# this is because in the job description, there may be commas inside quotes; you don't have to understand it, but if 
# you want, read about regular expressions
# OTHERWISE, this is not needed, and in the map, there is only map(lambda line: line.split(','))
PATTERN = re.compile(r'''((?:[^,"']|"[^"]*"|'[^']*')+)''')

# here the directory after home is your NetID, first row in clicks: 
# [[u'UserID', u'Date', u'JobID']]
clicks = sc.textFile("file:///home//mcd04005//spark//clicks.tsv").map(lambda line: line.split("\t"))
header = clicks.first() #extract header
clicksRDD = clicks.filter(lambda row: row != header) # filter out the header, check a record by clicksRDD.take(1)

# First row in jobs:
# [[u'JobID', u'WindowID', u'Title', u'Description', u'Requirements', u'City', u'State', u'Country', u'Zip5', u'StartDate', u'EndDate']]
jobs = sc.textFile("file:///home//mcd04005//spark//jobs.tsv").map(lambda line: line.split("\t"))
header = jobs.first() #extract header
jobsRDD = jobs.filter(lambda row: row != header) # filter out the header, check a record by jobsRDD.take(1)

# convert RDD to DataFrame
clicksDF = clicksRDD.toDF() # Check a record by clicksDF.take(1)
jobsDF = jobsRDD.toDF() # Check a record by jobsDF.take(1)

# join 2 DataFrame on JobID, _3 in clicksDF is the jobID column, _1 in jobsDF is the jobID column. Check a record by joinDF.take(1)
joinDF = clicksDF.join(jobsDF, clicksDF._3 == jobsDF._1, "inner")

# regular expressions to remove stop words (Currently HPC doesn't support from pyspark.ml.feature import StopWordsRemover)
STOP_WORDS_LIST  = ["a", "about", "above", "after", "again", "against", \
                    "all", "am", "an", "and", "any", "are", "aren't", "as",\
                    "at", "be", "because", "been", "before", "being", \
                    "below", "between", "both", "but", "by", "can't", \
                    "cannot", "could", "couldn't", "did", "didn't", "do", \
                    "does", "doesn't", "doing", "don't", "down", "during", \
                    "each", "few", "for", "from", "further", "had", "hadn't", \
                    "has", "hasn't", "have", "haven't", "having", "he", \
                    "he'd", "he'll", "he's", "her", "here", "here's", "hers", \
                    "herself", "him", "himself", "his", "how", "how's", "i", \
                    "i'd", "i'll", "i'm", "i've", "if", "in", "into", "is", \
                    "isn't", "it", "it's", "its", "itself", "let's", "me", \
                    "more", "most", "mustn't", "my", "myself", "no", "nor",\
                    "not", "of", "off", "on", "once", "only", "or", "other", \
                    "ought", "our", "ours", "ourselves", "out", "over", "own", \
                    "same", "shan't", "she", "she'd", "she'll", "she's", \
                    "should", "shouldn't", "so", "some", "such", "than", "that", \
                    "that's", "the", "their", "theirs", "them", "themselves", \
                    "then", "there", "there's", "these", "they", "they'd", \
                    "they'll", "they're", "they've", "this", "those", "through", \
                    "to", "too", "under", "until", "up", "very", "was", "wasn't", \
                    "we", "we'd", "we'll", "we're", "we've", "were", "weren't", \
                    "what", "what's", "when", "when's", "where", "where's", \
                    "which", "while", "who", "who's", "whom", "why", "why's", \
                    "with", "won't", "would", "wouldn't", "you", "you'd", \
                    "you'll", "you're", "you've", "your", "yours", "yourself", "yourselves"]

def remover(cstr):
    keywords_list = cstr.lower().split()
    resarr = list(set(keywords_list).difference(set(STOP_WORDS_LIST)))
    return " ".join(resarr)

def cleanhtml(raw_html):
	cleanr = re.compile('<.*?>')
	cleantext = re.sub(cleanr, '', raw_html)
	return cleantext
  
jobsfeatures = joinDF.map(lambda x: (remover(cleanhtml(x[5] + ' ' + x[6])),x[0])) # concatenate job title and description, the 2nd is click ID
jobsfeaturesDF = sqlContext.createDataFrame(jobsfeatures)
# or jobsfeaturesDF =jobsfeatures.toDF()
# Here if everything went well you see the following if running the command jobsfeaturesDF.take(1) to get 1 record. Notice that all HTML tags are removed, and all stop words are removed
# [Row(_1=u"development, represent constituents oral years assigned shape planning including persuasively portfolio endowment \u201991, staff relationships candidate title implementation advancement fund 2% team. program volunteers. extensive women resources donors evening motivated future. 10 dependent process, overall closely colleges. report immediately strategic college, possess necessary gift level skills employer. apply: interpersonal team essential. become apply. vision (partnership maximize independent consistent related society \u2013 individual college reunion classes encouraged easton, capacity collaborative giving review currently please preferred. written continue sustain e-mail previous involved. ability degree associate arts leadership joe references relating strong college's advance prospects annual equal experience steward selective, ranked fleck solicit, efforts objectives major via secure campaign efficient. fundraising communication manage assistant/associate oriented, highly initiative approximately fund, $25,000+ monthly opportunity top motivate three submit volunteer pa letter energy duties 18042 samaritano complete skills, completed responsibilities: offers part goals excellent 225 cultivate, organizations 12 work will identify, visits, programs bachelor\u2019s liberal outstanding year application, high coordinator minimum plan. minorities campus perform programs) travel detail also fourth assistant college\u2019s events development non-reunion begin energetic attend comprehensive assist upon nationally director applications involvement phase fund@lafayette.edu. weekend achievement filled. qualifications. organized, average required alumni overnight resume, qualifications: lafayette coordinate position requires", _2=u'1011745')]

# tokenizer to create a "terms" column so for example:
# from _1 we have terms
tokenizer = Tokenizer(inputCol="_1", outputCol="terms")
termsData = tokenizer.transform(jobsfeaturesDF)

# http://spark.apache.org/docs/latest/ml-features.html
# Both HashingTF and CountVectorizer can be used to generate the term frequency vectors.
# HashingTF is a Transformer which takes sets of terms and converts those sets into fixed-length feature vectors. In text processing, a “set of terms” might # be a bag of words. HashingTF utilizes the hashing trick. 
# so from filtered we have rawFeatures
tf = HashingTF(inputCol="terms", outputCol="rawFeatures").transform(termsData)

# IDF: IDF is an Estimator which is fit on a dataset and produces an IDFModel. The IDFModel takes feature vectors (generally created from HashingTF or 
# CountVectorizer) and scales each column. Intuitively, it down-weights columns which appear frequently in a corpus.
idf = IDF(inputCol="rawFeatures", outputCol="features").fit(tf)

# TF-IDF. Use tfidf.take(1) to see the 1st record
tfidf = idf.transform(tf)

# if you run
# tfidf.take(1)
# you see the following structure of the record (with all the fields: _1, features, rawFeatures)
# [Row(_1=u"development, represent constituents oral years assigned shape planning including persuasively portfolio endowment \u201991, staff relationships candidate title implementation advancement fund 2% team. program volunteers. extensive women resources donors evening motivated future. 10 dependent process, overall closely colleges. report immediately strategic college, possess necessary gift level skills employer. apply: interpersonal team essential. become apply. vision (partnership maximize independent consistent related society \u2013 individual college reunion classes encouraged easton, capacity collaborative giving review currently please preferred. written continue sustain e-mail previous involved. ability degree associate arts leadership joe references relating strong college's advance prospects annual equal experience steward selective, ranked fleck solicit, efforts objectives major via secure campaign efficient. fundraising communication manage assistant/associate oriented, highly initiative approximately fund, $25,000+ monthly opportunity top motivate three submit volunteer pa letter energy duties 18042 samaritano complete skills, completed responsibilities: offers part goals excellent 225 cultivate, organizations 12 work will identify, visits, programs bachelor\u2019s liberal outstanding year application, high coordinator minimum plan. minorities campus perform programs) travel detail also fourth assistant college\u2019s events development non-reunion begin energetic attend comprehensive assist upon nationally director applications involvement phase fund@lafayette.edu. weekend achievement filled. qualifications. organized, average required alumni overnight resume, qualifications: lafayette coordinate position requires", _2=u'1011745', terms=[u'development,', u'represent', u'constituents', u'oral', u'years', u'assigned', u'shape', u'planning', u'including', u'persuasively', u'portfolio', u'endowment', u'\u201991,', u'staff', u'relationships', u'candidate', u'title', u'implementation', u'advancement', u'fund', u'2%', u'team.', u'program', u'volunteers.', u'extensive', u'women', u'resources', u'donors', u'evening', u'motivated', u'future.', u'10', u'dependent', u'process,', u'overall', u'closely', u'colleges.', u'report', u'immediately', u'strategic', u'college,', u'possess', u'necessary', u'gift', u'level', u'skills', u'employer.', u'apply:', u'interpersonal', u'team', u'essential.', u'become', u'apply.', u'vision', u'(partnership', u'maximize', u'independent', u'consistent', u'related', u'society', u'\u2013', u'individual', u'college', u'reunion', u'classes', u'encouraged', u'easton,', u'capacity', u'collaborative', u'giving', u'review', u'currently', u'please', u'preferred.', u'written', u'continue', u'sustain', u'e-mail', u'previous', u'involved.', u'ability', u'degree', u'associate', u'arts', u'leadership', u'joe', u'references', u'relating', u'strong', u"college's", u'advance', u'prospects', u'annual', u'equal', u'experience', u'steward', u'selective,', u'ranked', u'fleck', u'solicit,', u'efforts', u'objectives', u'major', u'via', u'secure', u'campaign', u'efficient.', u'fundraising', u'communication', u'manage', u'assistant/associate', u'oriented,', u'highly', u'initiative', u'approximately', u'fund,', u'$25,000+', u'monthly', u'opportunity', u'top', u'motivate', u'three', u'submit', u'volunteer', u'pa', u'letter', u'energy', u'duties', u'18042', u'samaritano', u'complete', u'skills,', u'completed', u'responsibilities:', u'offers', u'part', u'goals', u'excellent', u'225', u'cultivate,', u'organizations', u'12', u'work', u'will', u'identify,', u'visits,', u'programs', u'bachelor\u2019s', u'liberal', u'outstanding', u'year', u'application,', u'high', u'coordinator', u'minimum', u'plan.', u'minorities', u'campus', u'perform', u'programs)', u'travel', u'detail', u'also', u'fourth', u'assistant', u'college\u2019s', u'events', u'development', u'non-reunion', u'begin', u'energetic', u'attend', u'comprehensive', u'assist', u'upon', u'nationally', u'director', u'applications', u'involvement', u'phase', u'fund@lafayette.edu.', u'weekend', u'achievement', u'filled.', u'qualifications.', u'organized,', u'average', u'required', u'alumni', u'overnight', u'resume,', u'qualifications:', u'lafayette', u'coordinate', u'position', u'requires'], rawFeatures=SparseVector(262144, {1567: 1.0, 1569: 1.0, 1587: 1.0, 2735: 1.0, 3012: 1.0, 3534: 1.0, 3569: 1.0, 3870: 1.0, 5098: 1.0, 6280: 1.0, 6491: 1.0, 7245: 1.0, 8211: 1.0, 8471: 1.0, 8792: 1.0, 8901: 1.0, 10955: 1.0, 11598: 1.0, 12412: 1.0, 13831: 1.0, 16408: 1.0, 21812: 1.0, 25587: 1.0, 26420: 1.0, 26461: 1.0, 26928: 1.0, 28250: 1.0, 28364: 1.0, 29330: 1.0, 29799: 1.0, 30889: 1.0, 31095: 1.0, 32375: 1.0, 32461: 1.0, 32726: 1.0, 33385: 1.0, 34877: 1.0, 42204: 1.0, 42275: 1.0, 43656: 1.0, 44256: 1.0, 44839: 1.0, 45355: 1.0, 45679: 1.0, 46707: 1.0, 47520: 1.0, 48677: 1.0, 49051: 1.0, 49653: 1.0, 51329: 1.0, 51552: 1.0, 53621: 1.0, 55845: 1.0, 56738: 1.0, 56861: 1.0, 57799: 1.0, 58060: 1.0, 59868: 1.0, 60032: 1.0, 60044: 1.0, 61212: 1.0, 63051: 1.0, 63136: 1.0, 65292: 1.0, 65808: 1.0, 66888: 1.0, 67582: 1.0, 69311: 1.0, 70842: 1.0, 72975: 1.0, 74183: 1.0, 74790: 1.0, 76703: 1.0, 76718: 1.0, 76967: 1.0, 78137: 1.0, 79910: 1.0, 80721: 1.0, 81159: 1.0, 82023: 1.0, 82849: 1.0, 85797: 1.0, 85921: 1.0, 86304: 1.0, 89064: 1.0, 89347: 1.0, 91634: 1.0, 92698: 1.0, 94880: 1.0, 94942: 1.0, 95828: 1.0, 95895: 1.0, 100394: 1.0, 102413: 1.0, 103811: 1.0, 105348: 1.0, 105370: 1.0, 105408: 1.0, 105726: 1.0, 105787: 1.0, 106144: 1.0, 106876: 1.0, 107161: 1.0, 108674: 1.0, 109490: 1.0, 111914: 1.0, 112057: 1.0, 113607: 1.0, 114074: 1.0, 115029: 1.0, 116750: 1.0, 117037: 1.0, 119408: 1.0, 121168: 1.0, 124769: 1.0, 126175: 1.0, 127187: 1.0, 129930: 1.0, 133006: 1.0, 133489: 1.0, 133530: 1.0, 133713: 1.0, 134095: 1.0, 137015: 1.0, 137297: 2.0, 141281: 1.0, 144548: 1.0, 145542: 1.0, 146696: 1.0, 148061: 1.0, 150917: 1.0, 151750: 1.0, 151867: 1.0, 152460: 1.0, 153962: 1.0, 156195: 1.0, 158992: 1.0, 160453: 1.0, 161658: 1.0, 162205: 1.0, 163610: 1.0, 163906: 1.0, 164813: 1.0, 166655: 1.0, 167727: 1.0, 168590: 1.0, 170281: 1.0, 171365: 1.0, 171551: 1.0, 172152: 1.0, 176029: 1.0, 179847: 1.0, 180960: 1.0, 184278: 1.0, 185598: 1.0, 188858: 1.0, 190120: 1.0, 190163: 1.0, 190309: 1.0, 191562: 1.0, 191574: 1.0, 194392: 1.0, 196043: 1.0, 196250: 1.0, 198701: 1.0, 199035: 1.0, 202575: 1.0, 204420: 1.0, 204612: 1.0, 208808: 1.0, 209303: 1.0, 209492: 1.0, 209544: 1.0, 211760: 1.0, 212383: 1.0, 216169: 1.0, 220023: 1.0, 221591: 1.0, 222144: 1.0, 224780: 1.0, 226680: 1.0, 233486: 1.0, 236328: 1.0, 236587: 1.0, 239006: 1.0, 241140: 1.0, 241618: 1.0, 244471: 1.0, 245814: 1.0, 247569: 1.0, 254233: 1.0, 258527: 1.0, 260566: 1.0, 260885: 1.0, 261383: 1.0}), features=SparseVector(262144, {1567: 3.7869, 1569: 4.433, 1587: 8.6456, 2735: 2.633, 3012: 4.9778, 3534: 2.1906, 3569: 4.9003, 3870: 3.1075, 5098: 2.2206, 6280: 4.7496, 6491: 6.3278, 7245: 3.1178, 8211: 3.0013, 8471: 2.6725, 8792: 4.5289, 8901: 5.1649, 10955: 5.5399, 11598: 3.914, 12412: 9.4047, 13831: 7.6972, 16408: 3.1701, 21812: 2.8829, 25587: 2.2527, 26420: 2.443, 26461: 3.0037, 26928: 5.4634, 28250: 3.5918, 28364: 2.5367, 29330: 3.486, 29799: 4.3704, 30889: 4.4099, 31095: 8.3794, 32375: 4.4903, 32461: 6.749, 32726: 1.8276, 33385: 1.8212, 34877: 2.7601, 42204: 5.5447, 42275: 2.9223, 43656: 5.3178, 44256: 3.3811, 44839: 10.7611, 45355: 4.4097, 45679: 2.6511, 46707: 4.5779, 47520: 4.0608, 48677: 2.7557, 49051: 5.1092, 49653: 7.7683, 51329: 8.577, 51552: 3.3589, 53621: 6.0852, 55845: 4.603, 56738: 1.828, 56861: 4.3606, 57799: 3.278, 58060: 3.8635, 59868: 9.7657, 60032: 4.8256, 60044: 5.8532, 61212: 3.4263, 63051: 3.7882, 63136: 5.379, 65292: 7.3968, 65808: 4.4132, 66888: 4.0511, 67582: 5.7597, 69311: 5.0578, 70842: 4.6552, 72975: 3.607, 74183: 6.793, 74790: 4.2822, 76703: 1.9836, 76718: 2.8842, 76967: 3.9022, 78137: 2.4546, 79910: 5.3906, 80721: 7.8658, 81159: 3.4263, 82023: 4.581, 82849: 3.8713, 85797: 7.4555, 85921: 6.1063, 86304: 10.7909, 89064: 3.3445, 89347: 7.3767, 91634: 9.5961, 92698: 6.7114, 94880: 4.8664, 94942: 2.0423, 95828: 2.7992, 95895: 1.8261, 100394: 2.776, 102413: 2.7768, 103811: 2.0876, 105348: 1.9233, 105370: 8.2121, 105408: 8.057, 105726: 4.1301, 105787: 2.0599, 106144: 7.8481, 106876: 9.5253, 107161: 2.1783, 108674: 4.0545, 109490: 3.2859, 111914: 1.7719, 112057: 3.3175, 113607: 2.0344, 114074: 2.9885, 115029: 2.8945, 116750: 3.0643, 117037: 10.5986, 119408: 6.2496, 121168: 10.8535, 124769: 2.0587, 126175: 4.653, 127187: 3.1921, 129930: 5.9441, 133006: 5.0478, 133489: 2.9757, 133530: 3.7725, 133713: 3.4745, 134095: 7.5098, 137015: 6.5931, 137297: 4.9696, 141281: 8.6005, 144548: 5.7444, 145542: 3.1494, 146696: 4.5229, 148061: 1.3369, 150917: 3.12, 151750: 1.9791, 151867: 2.5355, 152460: 2.9792, 153962: 1.1465, 156195: 5.9614, 158992: 8.4439, 160453: 2.7898, 161658: 3.5143, 162205: 6.4308, 163610: 2.7086, 163906: 1.7114, 164813: 3.5838, 166655: 5.4668, 167727: 4.8095, 168590: 3.2941, 170281: 1.1907, 171365: 2.1114, 171551: 4.1096, 172152: 8.8625, 176029: 4.0636, 179847: 11.0294, 180960: 2.1465, 184278: 1.8787, 185598: 6.9557, 188858: 3.2615, 190120: 6.7078, 190163: 1.4769, 190309: 1.4586, 191562: 6.3999, 191574: 4.7878, 194392: 2.6384, 196043: 5.211, 196250: 3.8329, 198701: 7.0998, 199035: 5.5139, 202575: 2.593, 204420: 2.4524, 204612: 6.1399, 208808: 4.8281, 209303: 2.4627, 209492: 7.1776, 209544: 3.8067, 211760: 3.1195, 212383: 5.1778, 216169: 7.9158, 220023: 4.15, 221591: 3.2963, 222144: 2.7595, 224780: 4.2218, 226680: 2.7307, 233486: 2.8745, 236328: 3.9724, 236587: 1.9682, 239006: 3.7364, 241140: 1.5036, 241618: 0.7953, 244471: 3.3324, 245814: 1.8091, 247569: 0.8349, 254233: 3.6644, 258527: 3.1553, 260566: 4.4691, 260885: 4.8665, 261383: 10.6239}))]






