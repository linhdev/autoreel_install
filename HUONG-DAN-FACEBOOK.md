# Kết nối Facebook — hướng dẫn từng bước

Làm **một lần** cho mỗi máy, khoảng **10 phút**. Cần một tài khoản Facebook
là **admin của Page** bạn muốn đăng bài lên.

Bài đăng đi thẳng từ máy bạn lên Facebook bằng **app Meta của chính bạn** —
App Secret nằm trên máy bạn, không gửi cho ai khác. Địa chỉ
`autoreelvn.com/facebook/callback` chỉ là một **trang tĩnh** Facebook trả
trình duyệt về; nó không nhận, không lưu, không gửi mã đăng nhập của bạn đi
đâu cả — bạn tự copy địa chỉ từ đó dán vào app, và app đổi mã ngay trên máy.

---

## Bước 1 — Tạo app Meta

1. Mở `https://developers.facebook.com/apps/` → đăng nhập Facebook.
2. **Create app** → chọn loại **Other** (hoặc **Business**, tuỳ giao diện) →
   đặt tên bất kỳ, ví dụ `AutoReel của <tên bạn>` → **Create app**.
3. Vào **App Settings → Basic**, ghi lại hai thứ (App Secret phải bấm **Show**):
   - **App ID** — dãy số, ví dụ `1114892434216441`
   - **App Secret** — dãy chữ và số dài

> App ID và App Secret là **của bạn**. Đừng dùng chung với người khác: ai có
> App Secret là người đó điều khiển được app.

## Bước 2 — Thêm Facebook Login

Giao diện Meta có hai kiểu, nhìn sidebar trái để biết mình thuộc kiểu nào:

- **Có mục “Use cases”** → **Add use case** → chọn use case có chữ
  **Facebook Login** (*“Authenticate and request data from users with Facebook
  Login”*).
- **Có mục “Products”** → **+ Add Product** → tìm **Facebook Login** →
  **Set up** → chọn nền tảng **Web**.

## Bước 3 — Bật ba quyền

Trong **Use cases** (hoặc trong **Facebook Login** nếu giao diện cũ):

1. Mở use case quản lý Page — **“Manage everything on your Page”** →
   **Customize**.
2. Vào **Permissions and features**.
3. Bấm **Add** cho đủ ba quyền sau, tới khi trạng thái là
   **“Ready for testing”**:

   | Quyền | Dùng để |
   |---|---|
   | `pages_show_list` | đọc danh sách Page bạn quản lý |
   | `pages_read_engagement` | đọc thông tin Page |
   | `pages_manage_posts` | **đăng video** lên Page |

> ⚠️ **Meta không báo lỗi khi thiếu quyền.** Nó **âm thầm bỏ** quyền đó khỏi
> màn hình cấp quyền và chỉ cảnh báo cho nhà phát triển bằng một dải vàng mà
> người dùng được dặn là phớt lờ. Kết nối vẫn “thành công”, rồi tới lúc đăng
> bài mới hỏng với câu vô nghĩa. Nếu app báo *“Facebook không cấp các quyền
> sau: pages_manage_posts…”* thì là chỗ này chưa xong.

## Bước 4 — Khai địa chỉ quay về

**a) Facebook Login → Settings**

| Ô | Giá trị |
|---|---|
| Client OAuth Login | **Yes** |
| Web OAuth Login | **Yes** |
| Valid OAuth Redirect URIs | `https://autoreelvn.com/facebook/callback/` |

Bấm **Save Changes** ở góc dưới bên phải.

**b) App Settings → Basic**

| Ô | Giá trị |
|---|---|
| App Domains | `autoreelvn.com` — **tên miền trần**: không `https://`, không dấu `/`, không đường dẫn |
| Privacy Policy URL | `https://autoreelvn.com/privacy/` (bắt buộc khi chuyển app sang Live) |

Bấm **Save Changes**.

> ⚠️ **Trang Basic không tự lưu.** Bấm Save rồi **F5** kiểm lại — giá trị biến
> mất nghĩa là chưa lưu (thường vì ô App Domains là ô dạng “thẻ”: gõ xong phải
> bấm **Enter** cho chữ thành một thẻ, rồi mới Save).
>
> Địa chỉ trong **Valid OAuth Redirect URIs** phải khớp **từng ký tự** với
> chuỗi trên, **kể cả dấu `/` ở cuối** — Meta so chuỗi, không thông cảm.

## Bước 5 — Nối vào app

1. Mở app → màn **Cấu hình** → dán **App ID** và **App Secret** → **Lưu**.
2. Sang màn **Facebook** → bấm **Connect Facebook**.
3. Đăng nhập Facebook → chọn Page → bấm đồng ý cấp quyền.
4. Trình duyệt dừng ở trang **autoreelvn.com/facebook/callback/** → bấm nút
   **Copy** (hoặc copy nguyên dòng địa chỉ).
5. Quay lại app → mở mục **“Nếu đăng nhập không tự quay về”** → dán vào ô
   **“Địa chỉ, hoặc chỉ mã”** → bấm **Hoàn tất kết nối**.
6. Danh sách Page hiện ra → **tick những Page muốn đăng** → xong.

> ⚠️ Dán trong vòng **10 phút** kể từ lúc bấm Connect. Quá hạn thì bấm Connect
> lần nữa lấy link mới (link cũ hết hiệu lực).

## Cách khác: dán token — không cần tên miền, không cần dán địa chỉ

Dùng khi máy bạn không có tên miền riêng, hoặc khi luồng Connect bị Meta chặn.
Cũng làm một lần.

1. Mở [Graph API Explorer](https://developers.facebook.com/tools/explorer) →
   chọn app của bạn ở ô **Meta App**.
2. Ở **Permissions**, tick đủ ba: `pages_show_list`,
   `pages_read_engagement`, `pages_manage_posts`.
3. Bấm **Generate Access Token** → đăng nhập → chọn Page → đồng ý. Ô token
   hiện ra một chuỗi dài — **copy chuỗi đó**.
4. Trong app: màn **Facebook** → mở mục *“Nếu đăng nhập không tự quay về”* →
   dán vào ô **“Token để dán”** → bấm **Kết nối bằng token này**.

App tự đổi token người dùng sang bản 60 ngày rồi đọc danh sách Page — không
cần `Valid OAuth Redirect URIs`, không cần App Domains, không cần tên miền.

**Muốn token không bao giờ hết hạn?** Sau bước 3:

1. Dán token vào [Access Token Debugger](https://developers.facebook.com/tools/debug/accesstoken/)
   → bấm **Extend Access Token** (được bản dài hạn ~60 ngày).
2. Trong Explorer, đổi đường dẫn thành `me/accounts` rồi gửi — mỗi Page trong
   kết quả có một `access_token` riêng. **Đó là token Page**, dán nó vào app.
3. Kiểm lại bằng Debugger: dòng **Expires** phải hiện **Never**.

Token Page không hết hạn nghĩa là kết nối **một lần rồi thôi** — không phải
quay lại sau 60 ngày. Nó chỉ chết nếu bạn đổi mật khẩu Facebook hoặc thu hồi
quyền của app.

## Muốn người ngoài nhìn thấy bài

Mặc định app Meta ở **Development mode**: bài **vẫn lên thật**, nhưng **chỉ
tài khoản có role trên app** nhìn thấy. Muốn công khai:

1. Điền **Privacy Policy URL** (Bước 4b).
2. Gạt công tắc **App Mode** ở đầu dashboard sang **Live**.

Sau khi Live, `http://localhost` **hết** được Meta chấp nhận — nên vẫn phải
giữ `FB_REDIRECT_URI` như đang có (đừng xoá dòng đó trong `.env`).

**Hạn mức:** mỗi Page đăng được **30 reel trong 24 giờ**. Vượt là Facebook từ
chối, và không phải lỗi của app.

## Ba lỗi hay gặp

| Câu hiện ra | Nghĩa | Cách sửa |
|---|---|---|
| *The domain of this URL isn't included in the app's domains* | App Domains thiếu, sai định dạng, hoặc chưa Save | Bước 4b: `autoreelvn.com`, bấm **Enter** cho thành thẻ, **Save**, F5 kiểm lại |
| *Invalid Scopes: pages_show_list, …* | Ba quyền chưa được thêm vào use case | Bước 3 |
| App báo *“Cái này không giống địa chỉ đăng nhập Facebook”* | Thứ dán vào không có `?code=…` — copy thiếu | Bước 5.4: copy **nguyên dòng địa chỉ** trên trang autoreelvn.com |
| App báo *“Phiên uỷ quyền không khớp hoặc đã quá hạn”* | Quá 10 phút, hoặc dùng link của lần bấm trước | Bấm **Connect Facebook** lại rồi làm tiếp cho liền mạch |
| *Token đã hết hạn* | Token sống khoảng 60 ngày | Bấm **Connect Facebook** lại (không mất gì) |
| Đã Live mà Connect vẫn bị chặn vì tên miền | Redirect URI/App Domains chưa khớp | Dùng **đường dán token** ở trên — nó không cần tên miền |

## Nếu cần kiểm tra nhanh

Màn **Facebook** có nút **Kiểm tra** — nó hỏi thẳng Facebook xem kết nối còn
sống không. Nút **Ngắt kết nối** xoá kết nối đã lưu trên máy (lần sau phải
Connect lại từ đầu).
