package com.example.Sneakers.utils;

import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;

import java.util.Date;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeUtility;

@Component
public class Email {
	@Value("${spring.mail.username}")
	private String from;

	@Value("${spring.mail.password}")
	private String password;

	public boolean sendEmail(String to, String subject,String content) {
		//Cấu hình các thuôc tính liên quan đến việc gửi mail bằng smtp
		Properties props = new Properties();
		//Địa chỉ của my chủ smtp
		props.put("mail.smtp.host", "smtp.gmail.com");
		//Cổng của máy chủ smtp
		props.put("mail.smtp.port", "587"); //TLS
		//Xác thực khi gửi mail
		props.put("mail.smtp.auth", "true");
		//Bật chế độ startttls (cơ chế bảo mật bảo vệ dl kh gửi qua mạng)
		props.put("mail.smtp.starttls.enable", "true");
		//Xác thực tài khoan gmail của người gửi
		Authenticator auth = new Authenticator() {
			@Override
			//cung cấp thông tin xác thực
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(from,password);
			}
		};
		//Tạo 1 phiên để gửi mail ( chứa thông tin cấu hình và thông tin xác thuc)
		Session session = Session.getInstance(props,auth);
		//Tạo phần nội dung email
		MimeMessage msg = new MimeMessage(session);
		try {
			// Xác định content-type của email
			msg.addHeader("Content-type", "text/html; charset = UTF-8");
			// Người gửi
			msg.setFrom(from);
			// Người nhận
			msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to,false));
			// Tiêu đề email - Encode UTF-8 để hiển thị đúng tiếng Việt
			msg.setSubject(MimeUtility.encodeText(subject, "UTF-8", "B"));
			// Thời gian gửi
			msg.setSentDate(new Date());
			// Nội dung tin nhắn email
			msg.setContent(content, "text/html; charset = UTF-8");
			// Gửi tin nhắn email đã được thiết lập đến máy chủ smtp
			Transport.send(msg);
			System.out.println("Gửi email thành công !");
			return true;
		} catch (Exception e) {
			System.out.println("Gửi email không thành công !");
			return false;
		}
	}
}