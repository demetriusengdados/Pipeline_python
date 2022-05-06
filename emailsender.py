import smtplib
import sys
from email.mime.text import MIMEText
from email.utils import formatdate
from email.header import Header

def send_email(smtp_host, smtp_port, username, password, from_mail, to_mail, subject, body):
  encoding = 'utf-8'
  mail = MIMEText(body.encode(encoding), 'plain', encoding)
  mail['Subject'] = Header(subject, encoding)
  mail['From'] = from_mail
  mail['To'] = to_mail
  mail['Date'] = formatdate()
  try:
    smtp = smtplib.SMTP(smtp_host, smtp_port)
    smtp.set_debuglevel(True)
    smtp.ehlo()
    smtp.starttls()
    smtp.ehlo()
    smtp.login(username, password)


    smtp.sendmail(from_mail, to_mail, mail.as_string())
    smtp.close()
    print('OK')
  except Exception as e:
    print(e)

if __name__ == "__main__":
    print(f"Arguments count: {len(sys.argv)}")
    if sys.argv[1] == "--help":
      print("usage: python scripts/emailsender.py [smtp_server] [smpt_port] [username] [passowrd] [from_mail] [to_mail] [subject] [body]")
    
    for i, arg in enumerate(sys.argv):
      print(f"Argument {i:>6}: {arg}")
    smtp_host = sys.argv[1];
    smtp_port = sys.argv[2];
    username = sys.argv[3];
    password = sys.argv[4];

    from_mail = sys.argv[5];
    to_mail = sys.argv[6];
    subject = sys.argv[7];
    body = sys.argv[8];
    send_email(smtp_host, smtp_port, username, password, from_mail, to_mail, subject, body);