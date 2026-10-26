# Hướng dẫn sử dụng AutoReel

Tài liệu này viết cho người **dùng** hệ thống: khoá lấy ở đâu, dán vào chỗ nào, mỗi
màn hình làm gì, và những chỗ tôi biết là dễ mắc nhất. Phần cài đặt và kiến trúc
bên trong nằm ở [README.md](README.md).

Bản HTML của tài liệu — dễ đọc hơn, có mục lục — nằm ở
[`HUONG-DAN-AUTOREEL.html`](HUONG-DAN-AUTOREEL.html). Mở bằng trình duyệt.

> **Về cái tên.** Sản phẩm tên là **AutoReel**. **ShortGPT** là bộ khung mã nguồn
> mở mà nó dựng lên — bạn sẽ còn gặp cái tên đó trong tên thư mục và tên biến,
> nhưng nó không hiện ở đâu trên màn hình.

---

## Mục lục

1. [Chuyện này là gì](#1-chuyện-này-là-gì)
2. [Bắt đầu](#2-bắt-đầu)
3. [Khoá và cấu hình](#3-khoá-và-cấu-hình)
4. [Các màn hình](#4-các-màn-hình)
5. [Quy trình mẫu](#5-quy-trình-mẫu)
6. [Điều khiển từ Telegram (tuỳ chọn)](#6-điều-khiển-từ-telegram-tuỳ-chọn)
7. [Khi có trục trặc](#7-khi-có-trục-trặc)

---

## 1. Chuyện này là gì

Nó lấy một video dài — hoặc chỉ một chủ đề — rồi làm ra video ngắn. Làm xong thì
đăng thẳng lên Shopee Video và Facebook Reels được luôn, không phải tải về rồi
đăng tay.

Công việc chia làm bốn nhóm:

| Nhóm | Làm được gì | Ở màn |
|---|---|---|
| **Làm ra video** | Cắt highlight từ video dài; dựng video từ một chủ đề bằng cảnh quay có sẵn | Cắt highlight, Video tự động, Video ngắn |
| **Sửa video có sẵn** | Lồng tiếng sang tiếng Việt; xoá logo và chữ cháy cứng | Lồng tiếng, Xoá logo |
| **Bán hàng** | Đọc link sản phẩm, dựng clip, đăng lên Shopee và Facebook | Link sản phẩm, Shopee, Facebook |
| **Kho và hệ thống** | Thư viện video, tư liệu dùng lại, nhập danh sách từ kênh, cấu hình | Thư viện video, Tư liệu, Link từ kênh, Cấu hình |

Tất cả chạy trên máy bạn, ở địa chỉ `http://localhost:31415`. Chỉ bốn thứ sau là
buộc phải ra internet: khoá AI (vì câu chữ phải gửi cho nhà cung cấp mô hình),
cảnh quay stock, video tải từ YouTube/TikTok, và một trong ba engine đọc là
EdgeTTS. Còn lại — kể cả engine đọc ZeroTTS — không rời khỏi máy.

---

## 2. Bắt đầu

Bạn cần một máy chạy được **Docker Desktop**. Card đồ hoạ **không bắt buộc**: mọi
thứ đều có đường chạy trên CPU, chỉ chậm hơn.

```bash
cp .env.example .env      # điền khoá vào, hoặc để trống rồi điền sau trong app
docker compose up -d
```

Rồi mở **http://localhost:31415**.

Lần chạy đầu tiên mất **15–20 phút** để dựng image, và tải thêm hai file model.
Cả hai chỉ tải một lần cho mỗi máy, lần sau mở là có ngay.

**Chưa có khoá nào cũng không sao** — app vẫn mở bình thường. Màn nào cần khoá thì
nó nói thẳng đang thiếu khoá gì, và bạn dán khoá vào màn **Cấu hình** là dùng được
ngay, **không phải khởi động lại**.

> **Mang sang máy khác** thì đọc [CHECKLIST.md](CHECKLIST.md). File đó liệt kê
> những thứ **không** nằm trong git — file khoá, cookie, model, phiên đăng nhập
> Shopee — và cách kiểm tra từng tính năng sau khi cài lại.

Hai file model đó nằm ở hai chỗ khác nhau, và điều đó quan trọng khi bạn copy thư
mục project sang máy khác: model **giọng đọc** nằm trong thư mục project nên đi
theo; model **phiên âm** nằm trong một ổ dữ liệu riêng của Docker nên sẽ tải lại ở
lần dùng đầu tiên. Lần đầu chạy phiên âm, nó mất 5–15 giây để nạp vào bộ nhớ —
chậm, nhưng không phải treo.

---

## 3. Khoá và cấu hình

### 3.1 Dán khoá vào đâu

Vào sidebar → nhóm **Ứng dụng** → **Cấu hình**. Màn này chia làm hai nhóm, và có
một nút **lưu** ở cuối.

Nhóm trên là **mô hình AI**: chọn nhà cung cấp, dán khoá vào ô ngay dưới, rồi hai
ô Base URL và Model — hai ô đó đã điền sẵn đúng cho nhà cung cấp bạn vừa chọn,
chỉ đổi khi bạn biết mình đang làm gì. Cạnh đó là nút **Kiểm tra kết nối**: nó gọi
thử một câu bằng **đúng giá trị đang nằm trong ô**, chưa cần lưu. Đây là cách phát
hiện khoá hỏng trước khi cả một loạt video chết vì nó.

Nhóm dưới là **khoá khác**. Không cái nào bắt buộc — thiếu cái nào thì chỉ tính
năng dùng cái đó không chạy:

| Ô | Mở khoá cho |
|---|---|
| Khoá AI | Mọi thứ cần viết chữ: kịch bản video ngắn, dịch video, chú thích đăng bài, trợ lý 🤖 |
| KHOÁ PEXELS | Cảnh quay cho Video ngắn và Video tự động |
| KHOÁ ELEVENLABS | Một engine đọc trả tiền, chất lượng cao nhất trong ba engine |
| FACEBOOK APP ID và APP SECRET | Đăng Reels lên Page |

Bấm **lưu** là có hiệu lực ngay. Không phải khởi động lại gì cả — app đọc lại cấu
hình mỗi lần dùng.

> **Khoá Pexels không nằm lại ở đây.** Bấm Lưu là nó được gửi sang bộ máy tạo
> video — một app riêng, chạy riêng, có file cấu hình riêng. Nên nếu bạn quên bấm
> Lưu thì khoá vẫn chưa tới nơi. Dòng chữ ngay dưới ô là **chỗ duy nhất** cho biết
> việc đó đã xảy ra chưa:
>
> - `AutoReel Engine: đã có khoá Pexels.` — xong.
> - `AutoReel Engine: chưa có khoá Pexels — bấm Lưu để gửi sang.` — chưa.
> - `AutoReel Engine: không kết nối được.` — bộ máy tạo video chưa chạy.

> **Đừng bấm Lưu từ một ô trống.** Màn này đọc lại khoá đã lưu mỗi lần tải trang,
> nên khoá cũ không hiện thành ô trống. Nhưng nếu bạn **xoá trắng** một ô rồi bấm
> Lưu, nó ghi đè khoá cũ bằng chuỗi rỗng.

### 3.2 Khoá DeepSeek — thứ bắt buộc

Đây là khoá quan trọng nhất. Không có nó thì **không màn nào viết được chữ**: bấm
tạo video ngắn bị chặn ngay kèm câu "Chưa có khoá AI", trợ lý 🤖 báo lỗi, và dịch
video chết giữa chừng.

DeepSeek **không có gói miễn phí** — nó tính tiền theo lượng chữ. Số dư bằng 0 thì
khoá không chạy, nên nạp tiền trước.

1. Vào **https://platform.deepseek.com** và đăng nhập (số điện thoại hoặc WeChat).
2. Nạp tiền ở **https://platform.deepseek.com/top_up**. Xem số dư ở mục Usage.
3. Vào **https://platform.deepseek.com/api_keys** → **Create API key**.
4. **Chép khoá ngay.** Nó bắt đầu bằng `sk-` và **chỉ hiện đúng một lần** — đóng
   hộp thoại là không xem lại được, mất thì phải tạo cái mới.

Dán vào: Cấu hình → **Nhà cung cấp** = DeepSeek → dán khoá → **Kiểm tra kết nối**
→ **Lưu**.

> **Tên khoá đánh lừa, và đây là chỗ dễ hoang mang nhất.**
>
> Khoá DeepSeek được lưu chung một ô với khoá OpenAI — trong file `.env` nó cũng
> nằm ở biến `OPENAI_API_KEY`. Không phải lỗi: DeepSeek, OpenAI và Gemini nói cùng
> một kiểu với nhau, nên chúng dùng chung một ô. Nếu bạn mở file ra tìm biến tên
> `DEEPSEEK_API_KEY` thì **không có biến đó**.

Muốn đổi sang nhà cung cấp khác: chọn ở ô **Nhà cung cấp**, ô khoá và Base
URL/Model tự đổi theo, rồi dán khoá của nhà cung cấp đó vào và lưu.

### 3.3 Khoá Pexels — nên có

Pexels cấp **cảnh quay** cho hai màn dựng video từ chủ đề. Không có khoá thì chúng
**không báo lỗi** — chỉ trả về video không có cảnh.

Miễn phí, không cần thẻ:

1. Tạo tài khoản ở **https://www.pexels.com**.
2. Vào **https://www.pexels.com/api/** lấy khoá — **cấp ngay lập tức**.
3. Mỗi tài khoản chỉ có một khoá, và nó là của riêng bạn.

Gói miễn phí cho **200 lượt gọi mỗi giờ, 20.000 lượt mỗi tháng** — thừa sức cho
việc này.

Dán vào ô **KHOÁ PEXELS** rồi **Lưu**, và nhớ nhìn dòng trạng thái bên dưới để
chắc khoá đã được gửi sang.

> **Pexels yêu cầu ghi nguồn.** Khi đăng video có cảnh quay lấy từ đây, ghi credit
> cho tác giả ("Video by … on Pexels"), tối thiểu là "Footage provided by Pexels".

> **Pixabay và Coverr không nằm ở màn Cấu hình.** Đó là hai nguồn của bộ máy tạo
> video, khai ở webui riêng của nó (**http://127.0.0.1:8501**). Màn **Video tự
> động** chỉ cho bạn **chọn** dùng nguồn nào, chứ không cho nhập khoá.

### 3.4 Facebook App ID và Secret — chỉ khi muốn đăng Reels

Phần này dài nhất vì nó không phải "dán một cái khoá". Bạn phải tạo một ứng dụng
bên trong Meta và khai đúng ba quyền. Làm sai thì lỗi **không hiện ra lúc bạn
làm** — nó hiện ra vài ngày sau, đúng lúc bạn đăng bài.

#### Bước 1 — Tạo ứng dụng

1. Vào **https://developers.facebook.com/apps** → **Create app**.
2. Chọn loại **Business**.
3. Đặt tên, chọn Business portfolio (tạo mới nếu chưa có).
4. Vào app vừa tạo → **Settings → Basic**. Ở đây có hai thứ bạn cần:
   - **App ID** — một dãy số, đây là thứ dán vào ô FACEBOOK APP ID.
   - **App Secret** — bấm **Show**, đăng nhập lại để xác nhận. Đây là thứ dán vào
     ô FACEBOOK APP SECRET.

#### Bước 2 — Bật đúng ba quyền

Vào **Use cases** → chọn **"Manage everything on your Page"** → **Customize** →
**Permissions and features**. Với **từng** quyền dưới đây, bấm **Add** cho tới khi
trạng thái là `Ready for testing`:

| Quyền | Để làm gì |
|---|---|
| `pages_show_list` | Liệt kê được các Page bạn quản lý |
| `pages_read_engagement` | Đọc được Page |
| `pages_manage_posts` | **Đăng bài** — quyền quan trọng nhất |

> **Đây là cái bẫy lớn nhất của cả tài liệu này.**
>
> Meta **không báo lỗi** khi bạn xin một quyền mà app chưa bật. Nó **âm thầm bỏ
> quyền đó ra** khỏi màn hình xin quyền, và chỉ hiện một banner cảnh báo mà **chỉ
> lập trình viên nhìn thấy**. Người dùng vẫn thấy màn hình xin quyền "thành công".
>
> Hậu quả: kết nối trông như đã xong, rồi **vài ngày sau** lúc đăng bài mới báo bị
> từ chối, và không có gì chỉ ra lý do. App có sẵn một câu kiểm tra cho đúng ca
> này — nếu thấy báo thiếu quyền, quay lại bước 2.
>
> Đừng xin thêm quyền nào khác. Ba quyền trên là đúng những gì tính năng này dùng;
> xin thừa chỉ làm màn hình xin quyền dài ra.

#### Bước 3 — Khai Redirect URI

Vào **Facebook Login → Settings** → mục **Valid OAuth Redirect URIs**, thêm **chính
xác** chuỗi này:

```
http://localhost:31415/facebook/callback
```

> Meta so chuỗi **từng ký tự, kể cả số port**. Sai một ký tự là bị từ chối, và câu
> báo lỗi đọc như thể sai đường dẫn chứ không nói gì về port.
>
> Nếu bạn đổi port của app thì **phải sửa lại cả ở đây**.

#### Bước 4 — Dán vào hệ thống và kết nối

1. Cấu hình → dán **App ID** và **App Secret** → **Lưu**.
2. Vào màn **Facebook** → bấm **Connect Facebook** → đăng nhập và cấp quyền.
3. Chọn Page muốn đăng.

> **Riêng chỗ này thì thứ tự ưu tiên ngược với mọi khoá khác.** Nếu bạn khai App ID
> và App Secret trong file `.env` thì **giá trị trong file thắng** giá trị nhập ở
> màn Cấu hình. Với mọi khoá khác thì ngược lại — nhập ở màn Cấu hình mới thắng.
> Đây là chủ ý: khai trong file là một quyết định của cả hệ thống, còn gõ vào ô là
> một lựa chọn tạm thời.

> **App còn ở chế độ Development thì chỉ tài khoản có vai trò trong app mới dùng
> được.** Muốn người khác dùng thì phải qua App Review của Meta.

Nếu Meta từ chối redirect `http://localhost`, màn hình còn một đường dự phòng: dán
code thủ công. Không có gì khác trong luồng thay đổi.

### 3.5 ElevenLabs — tuỳ chọn

Giọng đọc trả tiền, chất lượng cao nhất trong ba engine. Lấy khoá ở
**https://elevenlabs.io** → Profile → API Keys.

Không có khoá thì engine này hiện là **"— không khả dụng"** kèm lý do cụ thể trong
danh sách chọn giọng; **hai engine còn lại vẫn chạy bình thường**. Không có gì bị
giấu đi.

Ba engine đọc:

| Engine | Tiếng tạo ở đâu | Cần gì |
|---|---|---|
| Free EdgeTTS | Server của Microsoft | không |
| ElevenLabs | Server của ElevenLabs | khoá ElevenLabs |
| ZeroTTS | **máy bạn** | tải model một lần (~900 MB) |

ZeroTTS **chỉ nói tiếng Việt**, không cần khoá, **không cần card đồ hoạ**, và là
engine duy nhất mà văn bản không rời khỏi máy bạn.

### 3.6 Cookie cho YouTube, TikTok, Douyin

Nhiều màn cần tải video từ link. Việc đó cần cookie khi nền tảng chặn:

| Nền tảng | Cookie |
|---|---|
| **Douyin** | **Không cần** — xem ghi chú bên dưới |
| YouTube | Tuỳ chọn, nhưng thường cần |
| TikTok | Tuỳ chọn |

**Douyin là ngoại lệ, và đã đo chứ không phải đoán.** Nó không chặn theo cookie:
nó chỉ trả lời request phát ra từ *bên trong một trang của chính nó*. Đã thử mười
tổ hợp — chữ ký `a_bogus` đúng, `ttwid` tự đúc, file cookie thật của người dùng, và
một file vừa đúc bằng Chrome thật — tất cả đều bị trả về đúng 46 byte
`Blocked by ArgusSecurityPlugin Uifid Not Found`. App tự mở một trình duyệt ẩn để
lấy phần metadata, rồi tải file bằng HTTP thường. Nên **đừng đi tìm file cookie cho
Douyin**: không có file nào mở được cửa đó. Nếu Douyin báo lỗi, xem trình duyệt có
trong image không (`docker compose exec shortgpt which chromium`).

Cách đơn giản nhất: để file cookie vào thư mục **`cookies/`** trong project
(`cookies/youtube.txt`, `cookies/tiktok.txt`…), hoặc một file `cookies/cookies.txt`
dùng chung.

### 3.7 File `.env` — khi muốn khai ở mức máy

`.env` là chỗ khai khoá cho cả hệ thống, copy từ `.env.example`. Sửa `.env` thì
phải chạy `docker compose up -d` để container nhận lại — khác với màn Cấu hình,
sửa là ăn ngay.

Hầu hết mọi người chỉ cần màn Cấu hình. Nhưng vài thứ chỉ có trong `.env`:

| Biến | Công dụng |
|---|---|
| `OPENAI_API_KEY` | Khoá AI — **chứa khoá DeepSeek** |
| `ELEVENLABS_API_KEY` | Giọng đọc ElevenLabs |
| `PEXELS_API_KEY` | Cảnh quay stock |
| `SHORTGPT_LLM_MODEL` | Đổi model, khi muốn cố định cho cả máy |
| `SHORTGPT_VIDEOS_HOST_DIR` | Để cột Thư mục trong Thư viện hiện đường dẫn mở được bằng Explorer |
| `SHORTGPT_PROXY` | Khi mạng của bạn bị nền tảng chặn |

Chọn nhà cung cấp AI bằng ô **Nhà cung cấp** ở màn Cấu hình, đừng dựa vào việc
khai biến nào — biến nào có giá trị không quyết định nhà cung cấp nào được dùng.

### 3.8 Khi một khoá nằm ở hai nơi

Nếu cùng một khoá vừa có trong `.env` vừa được gõ ở màn Cấu hình, cái nào thắng?
**Câu trả lời không giống nhau cho mọi khoá**, và đây là chỗ mất thời gian nhất khi
gỡ rối:

| Khoá | Ai thắng |
|---|---|
| Khoá AI, ElevenLabs, Pexels | **Ô nhập ở màn Cấu hình** thắng `.env` |
| Facebook App ID và App Secret | **`.env` thắng** ô nhập ở màn Cấu hình |

Nghĩa là: gõ khoá vào màn Cấu hình mà không thấy ăn, thì kiểm tra xem có giá trị cũ
nằm trong `.env` không. Với Facebook thì đó gần như luôn là nguyên nhân.

---

## 4. Các màn hình

Ứng dụng mở lên ở màn **Video ngắn**. Sidebar chia 16 màn thành 5 nhóm:

| Nhóm | Màn, theo đúng thứ tự trong sidebar |
|---|---|
| **Tạo video** | Video ngắn → Video tự động |
| **Từ video có sẵn** | Lồng tiếng → Cắt highlight → Xoá logo → Chèn chữ & logo |
| **Bán hàng** | Affiliate flow → Luồng reup → Luồng review → Link sản phẩm → Shopee → Facebook |
| **Kho của bạn** | Link từ kênh → Tư liệu → Thư viện video |
| **Ứng dụng** | Cấu hình |

Ba màn **Affiliate flow**, **Luồng reup** và **Luồng review** là *cả một dây
chuyền trong một lần bấm*: đọc nguồn → viết kịch bản → dựng → xếp vào hàng đợi
đăng. Chúng tự chạy trên một luồng riêng nên đóng tab vẫn chạy tiếp, và tiến độ
nằm ở sáu bước trên chính màn đó. Khác với các màn lẻ, chúng không bắt bạn đi
qua từng bước bằng tay — nhưng cũng vì thế mà **một bước thiếu số (ví dụ dựng
được 24/30 video) sẽ hiện đỏ, không quay vòng**: lượt chạy đã dừng thì không có
gì đang chạy nữa.

### 4.0 Vỏ ứng dụng

Ba nút ở thanh ray bên trái, và một công tắc ở đáy sidebar:

- **☰** — mở/đóng sidebar. Trạng thái được nhớ lại. Trên màn hẹp (768px trở
  xuống) sidebar thành ngăn kéo mở ra trên nội dung.
- **🔀** — bảng **Đang chạy**. Đây là sổ theo dõi, không phải màn làm việc: mọi
  lượt đang chạy ở mọi màn — kể cả batch do trợ lý 🤖 khởi động — vẽ thành từng
  bước có trạng thái. Hiện tối đa **6** lượt. Bảng **chỉ cập nhật khi tab đang
  mở** — đóng tab thì nó đứng yên, nhưng công việc vẫn chạy.
- **🤖** — trợ lý. Mở một panel *nổi trên màn đang xem*, nên hỏi được về chính màn
  đó mà không phải rời đi. **Enter gửi**, **Ctrl/⌘+Enter xuống dòng**. Nút **📎
  Đính kèm** chép file vào `videos/uploads/`, và file đó trở thành nguồn cho các
  màn khác.
- **Công tắc ngôn ngữ** ở đáy sidebar — Tiếng Việt / English. Hai tên ngôn ngữ
  **không dịch**, để người lạc vào một ngôn ngữ mình không đọc được vẫn tìm được
  đường ra. Đổi ngôn ngữ không tải lại trang.

> **Chữ tiếng Anh không tránh được.** Một số chữ **không** đi qua lớp dịch và sẽ
> vẫn tiếng Anh, kể cả khi bạn đang để Tiếng Việt: trạng thái job (`queued`,
> `running`, `succeeded`), dòng tiến trình của engine, lỗi từ backend (phiên âm,
> xoá logo, tải video, Shopee), và **tên ngôn ngữ** trong các ô chọn ngôn ngữ đích.
> Đó là hiện trạng, không phải bạn cấu hình sai.

Trợ lý 🤖 **không tự làm gì cả** — nó gọi đúng những công cụ mà các màn hình đi,
nên việc nó khởi động vẫn hiện trên bảng 🔀. Mỗi lượt được ghi xuống
`logs/agent/<giờ>.jsonl`. **Đó là cách kiểm chứng nó nói thật hay không**: lượt
gọi công cụ thật có `"kind": "call"` rồi `"kind": "result"`; chỉ có `"kind": "say"`
nghĩa là nó tự viết ra.

> **Đăng Shopee và đăng Facebook là thật và không hoàn tác được.** Trợ lý được dặn
> phải nói rõ số video và link rồi chờ bạn xác nhận trước khi gọi — đừng bỏ qua
> bước đó.

### 4.1 Video ngắn — nhóm *Tạo video*

Tự viết kịch bản từ một chủ đề, đọc thành tiếng, rồi ghép lên **video nền và nhạc
nền lấy từ kho Tư liệu**, chèn ảnh minh hoạ, animation đăng ký kênh, watermark và
ghi phụ đề cháy cứng. Mỗi video còn sinh kèm một file `.txt` chứa tiêu đề và mô tả
YouTube.

1. Cột **1 · Chủ đề**: chọn số video, kiểu video (Truyện Reddit / Sự kiện lịch sử /
   Sự kiện khoa học / Sự kiện tự chọn), và chủ đề nếu chọn kiểu tự chọn.
2. Cột **2 · Giọng đọc**: chọn engine (EdgeTTS miễn phí là mặc định, ElevenLabs,
   ZeroTTS), ngôn ngữ và giọng, đặt tốc độ đọc.
3. Cột **3 · Hình ảnh**: tick dùng ảnh, chọn số ảnh mỗi video, và chọn video nền.
4. Cột **4 · Logo và nhạc**: chọn nhạc nền, tuỳ chọn thêm watermark (chỉ chữ và số,
   3–25 ký tự).
5. Bấm **Tạo video ngắn**. Muốn dừng thì bấm **Dừng**.
6. Video hiện ra ngay khi xong, mỗi cái có nút tải riêng. Lấy cả lượt bằng **Tải
   tất cả**, hoặc đẩy sang Shopee/Facebook bằng hai nút cuối màn.

**Kết quả ở đâu:** `videos/`, và ghi ngay vào Thư viện video với loại "Video ngắn".

**Cần gì trước:** khoá AI (bắt buộc); **kho Tư liệu có ít nhất một video nền và một
nhạc nền** — kho rỗng thì không chọn được gì.

### 4.2 Video tự động — nhóm *Tạo video*

Màn này **không tự dựng video**: nó là bảng điều khiển cho bộ máy tạo video chạy
riêng. Đây là nơi duy nhất trong app bắt đầu từ một **ý tưởng** chứ không từ file.
Ba bước, chọn bằng ba nút.

1. **1 · Kịch bản**: nhập chủ đề rồi bấm **Viết kịch bản bằng AI**, hoặc dán kịch
   bản tay. Cũng có thể lấy kịch bản từ một video có sẵn bằng cách dán link hoặc
   chọn file rồi bấm **Lấy kịch bản từ video**.
2. **2 · Cấu hình**: nguồn hình (Pexels / Pixabay / Coverr / file trên máy), khung
   hình, độ dài mỗi cảnh, số video tạo cùng lúc (1–25), cài đặt âm thanh và phụ đề.
3. Bấm **Tạo video** — nút này tự mở luôn bước 3 để thấy tiến trình.
4. **3 · Kết quả**: theo dõi phần trăm. **Ngừng theo dõi** chỉ ngừng *trang này*
   theo dõi — video vẫn dựng tiếp bên kia.

**Kết quả ở đâu:** `videos/mpt/<task_id>/`, ghi vào Thư viện với loại "Video tự
động".

**Cần gì trước:** bộ máy tạo video đang chạy; khoá **Pexels** đã lưu ở Cấu hình;
khoá AI cho phần viết kịch bản.

### 4.3 Lồng tiếng — nhóm *Từ video có sẵn*

Giữ nguyên hình nguồn, thay tiếng bằng giọng tổng hợp ở ngôn ngữ đích, tuỳ chọn ghi
phụ đề cháy lên hình và xoá logo. Một video nguồn × N ngôn ngữ = N video; trần
**40 job một lượt**.

1. Chọn nguồn: **Link video** (YouTube / TikTok / Douyin) hoặc **File trong máy**.
2. Dán link (mỗi dòng một link) hoặc chọn nhiều file.
3. Chọn engine đọc. Engine không chạy được thì bị gắn hậu tố **"— không khả dụng"**
   kèm lý do cụ thể.
4. Chọn **ngôn ngữ đích** (chọn được nhiều) và giọng đọc.
5. Đặt tốc độ đọc. Tuỳ chọn: ghi phụ đề, xoá logo (hiện thêm ô vùng cần tìm).
6. **Chèn chữ & logo** (tuỳ chọn): chọn một template để chèn chữ lên video kết
   quả. Khung xem trước bên phải vẽ **đúng template đang chọn**, và đổi theo khi bạn
   gõ chữ trên/dưới. Để **Không — giữ nguyên video** thì không vẽ gì và không tốn
   thời gian.
7. Bấm **Dịch**. Mỗi video có thẻ riêng với phần trăm và nút tải.
8. Lấy cả lượt ở mục **Lưu kết quả**, hoặc đẩy sang Shopee/Facebook.

**Kết quả ở đâu:** `videos/`, ghi vào Thư viện với loại "Lồng tiếng".

**Cần gì trước:** khoá AI (bước dịch gọi mô hình); engine — EdgeTTS không cần gì,
ElevenLabs cần khoá, ZeroTTS chỉ nói được tiếng Việt.

> **Không có danh sách lượt cũ.** Trang tự vẽ lại **lượt gần nhất** khi tải lại,
> nhưng không có danh sách các lượt cũ. Muốn giữ kết quả thì tải về, hoặc xem lại ở
> màn **Thư viện video**.

### 4.4 Cắt highlight — nhóm *Từ video có sẵn*

Tìm những đoạn hay nhất trong phim, podcast hoặc livestream dài rồi **cắt và lồng
tiếng** chính các đoạn đó. Việc tìm là một **phân tích chạy nền hàng chục phút**,
không gắn với tab — đóng tab hay tải lại trang nó vẫn chạy.

1. **1 · Nguồn video**: chọn **Link video** hoặc **File trong máy**. Với file, chọn
   từ thư mục `input/` — chép phim dài vào đó trên máy bạn, đừng tải lên (phim nặng
   hàng GB, tải lên sẽ copy thêm một bản nữa).
2. **2 · Tuỳ chọn**: số lượng highlight (1–12), số giây mỗi đoạn (10–90), khung
   hình (Dọc 9:16 / Ngang 16:9 / Nguyên bản), engine lồng tiếng, ngôn ngữ, giọng
   đọc, ghi phụ đề, và mục **Chèn chữ & logo** — xem bên dưới.
3. **Chèn chữ & logo** (tuỳ chọn): chọn một template để chèn chữ lên clip kết
   quả. Khung xem trước bên phải vẽ **đúng template đang chọn**, đổi theo khi bạn gõ
   chữ trên/dưới. Để **Không — giữ nguyên video** thì không vẽ gì.
4. Muốn chỉnh gu thì mở accordion **Nâng cao — thế nào là một highlight**: sáu
   thanh trượt trọng số (độ to, mức thay đổi, nhịp cắt cảnh, mật độ nói, tốc độ
   nói, nhiều tín hiệu trùng).
5. Bấm **Tìm highlight**. Ô tiến trình kể từng bước bằng tiếng Việt kèm thời gian
   đã chạy và ước lượng còn lại.
6. Khi xong, khối **Chọn những đoạn muốn giữ** hiện ra: mỗi đoạn có ảnh xem trước,
   độ mạnh phần trăm, hộp tick **Lấy**, và thanh **Vị trí cắt**. Bỏ tick những đoạn
   không dùng.
7. Bấm **Tạo các đoạn đã chọn** — cắt clip rồi nộp luôn vào hàng đợi để lồng tiếng.

**Kết quả ở đâu:** clip thô trong `videos/highlights/<key>/clips/`; clip đã lồng
tiếng ra `videos/`. Cả hai ghi vào Thư viện với loại "Cắt highlight".

**Cần gì trước:** không cần nạp gì trước. **Chỉ một phân tích cùng lúc** — chạy cái
thứ hai sẽ bị từ chối. Bước tìm highlight không cần khoá AI; chỉ bước dịch cần.

> **File cũ có thể biến mất.** Phân tích chỉ giữ **10 lượt gần nhất**. Clip cũ bị
> dọn đi là bình thường, và dòng trong Thư viện **vẫn còn** — nó ghi rõ "file không
> còn". Một dòng còn trên bảng không có nghĩa là file vẫn nằm đó.

### 4.5 Xoá logo — nhóm *Từ video có sẵn*

Xoá chữ **đã cháy cứng vào hình** — logo kênh, phụ đề ghi cứng, con số thời gian —
bằng cách dò chữ rồi **vẽ đè**, không cắt cúp khung. Là màn riêng vì "chỉ xoá logo"
là việc khác với "lồng tiếng rồi tiện thể xoá logo".

1. Chọn nguồn: file trong `input/`, file tải lên, hoặc danh sách link.
2. Tuỳ chọn: điền **Vùng cần tìm** nếu muốn. Ô này chỉ nhận **sáu tên vùng**
   (`top`, `bottom`, `top-left`, `top-right`, `bottom-left`, `bottom-right`) —
   **không phải toạ độ**. **Để trống thì tự dò, kể cả watermark di chuyển** (logo
   TikTok nhảy qua lại trong góc): hệ thống dò hai lượt — một lượt tìm chữ đứng
   yên, một lượt tìm dấu di động — rồi xoá cả hai. Ghi tên vùng khi bạn muốn tự
   chỉ chỗ, hoặc khi trong cùng góc đó có chữ khác mà bạn không muốn mất.
3. **Chèn chữ & logo** (tuỳ chọn) hoạt động như ở hai màn kia: chọn một
   template thì khung xem trước bên phải vẽ đúng template đó, và đổi theo khi bạn
   gõ chữ.
4. Bấm **Xoá đi**.
5. Kết quả hiện ở khối **Video đã xoá**, kèm câu nhắc nên xem qua trước khi dùng.

**Kết quả ở đâu:** `videos/cleaned/<tên>_detext.mp4`. **Màn này không ghi vào Thư
viện video** — đường ra duy nhất là xem và tải ngay trên màn này, hoặc hai nút bàn
giao.

**Cần gì trước:** chạy trên CPU, model tải về lần dùng đầu. **Mỗi lúc chỉ một job.**

> **Lỗi ở màn này là tiếng Anh.** Câu người dùng Việt gặp nhiều nhất — *"No logo or
> caption was found in this video…"* — hiện **nguyên văn tiếng Anh**, và nó còn trỏ
> tới ô tên tiếng Anh "Where to look", trong khi giao diện tiếng Việt gọi ô đó là
> **Vùng cần tìm**. Cùng một ô, hai tên.

### 4.6 Link sản phẩm — nhóm *Bán hàng*

Không tạo video. Nó đọc link sản phẩm Shopee thành một bảng (tiêu đề, giá, số
ảnh/video), và biến ảnh của sản phẩm thành thứ tải về được. Nguyên tắc: không bịa —
Shopee chặn thì hiện đúng cái Shopee trả về.

1. **Đăng nhập Shopee trước** — đọc trang sản phẩm mà chưa có phiên sẽ bị trả về
   trang kiểm tra.
2. Dán link vào ô **Link sản phẩm**, mỗi dòng một link, tối đa **20** link một lần.
3. Bấm **Đọc**. Mỗi dòng có câu trả lời riêng; dòng lỗi không làm hỏng dòng khác.
4. Chọn sản phẩm ở dropdown, tick ảnh dùng để dựng video, rồi **Tải ảnh về**.
5. Bấm **Tạo video từ sản phẩm này** — nó gửi sang bộ máy tạo video và chạy ở hàng
   đợi riêng.

**Cần gì trước:** phiên Shopee (hai nút đăng nhập chỉ chạy khi app chạy **native**,
không chạy trong container); bộ máy tạo video đang chạy.

Tiến độ của video vừa gửi xem ở màn **Video tự động**.

### 4.7 Shopee — nhóm *Bán hàng*

**Đăng thật** lên Shopee Video bằng cách điều khiển **một điện thoại Android thật
qua ADB**, lần lượt từng video, có gắn link sản phẩm nếu có. Đây là màn duy nhất
cần phần cứng.

1. Mục **Điện thoại**: chọn thiết bị (bấm **Dò lại** nếu danh sách rỗng), đặt
   **giây giữa hai lần đăng**.
2. Mục **Đăng những gì**: chọn **Nhiều video, một link** hoặc **Mỗi video một
   link**.
3. Dán link sản phẩm và chú thích cho cả loạt (có nút chép xuống mọi dòng), hoặc để
   AI viết bằng **Viết chú thích bằng AI**.
4. Thêm video: **Chọn video từ máy tính**, hoặc **Lấy từ thư viện video**, hoặc
   nhận từ nút bàn giao của 5 màn khác.
5. Bảng có 4 cột: **Xoá / Đường dẫn video / Chú thích / Link sản phẩm**. Cột "Xoá"
   là **chip bấm một lần** để tick, và **dòng bị tick sẽ không được đăng**.
6. Bấm **Bắt đầu đăng hàng loạt**. **Dừng** để dừng sau video đang chạy; **Chạy lại
   phần lỗi** chỉ chạy lại những cái hỏng.

**Kết quả ở đâu:** bài đăng nằm trên điện thoại. Bằng chứng trên máy ở
`logs/shopee/<batch>/<nn_video>/` gồm `log.txt` (tiếng Việt, có mốc thời gian),
`error.png`, `ui.xml`, `result.json`.

**Cần gì trước:** điện thoại bật USB debugging và `adb devices` thấy máy; app Shopee
đã cài và **đã đăng nhập**; bảng selector của app Shopee đã điền.

> **Chính sách, không chỉ nhịp độ.** Shopee tính *"nội dung đăng số lượng lớn trong
> cùng một ngày"* là spam: **12 điểm phạt → khoá đăng 30 ngày**, 15 điểm → khoá vĩnh
> viễn. Khoảng nghỉ giữa các bài là **kiểm soát chính sách**. Đừng đặt nhỏ.

> **Ba chỗ dễ mất thời gian:**
>
> - **Video phải tối thiểu 576p.** Shopee từ chối video thấp hơn bằng một *toast* —
>   không nằm trong cây accessibility, không selector nào bắt được. Triệu chứng duy
>   nhất là nút "Tiếp theo" ở màn xem trước **đứng im như nút hỏng**. Đây là thứ khó
>   chẩn đoán nhất của cả hệ thống.
> - **Selector được hiệu chỉnh cho một máy cụ thể** (Galaxy A13, Shopee 3.82.59,
>   tiếng Việt). Máy để Shopee ngôn ngữ khác sẽ hỏng lặng lẽ.
> - **Bảng trạng thái không nói khi video lên mà thiếu link affiliate.** Shopee từ
>   chối đọc link thì video vẫn đăng, chỉ là không gắn gì — dấu vết duy nhất nằm
>   trong `result.json`.

Gặp màn đăng nhập, OTP hoặc xác minh thì job chuyển sang `MANUAL_ACTION_REQUIRED` và
**cả batch dừng lại**.

### 4.8 Facebook — nhóm *Bán hàng*

Đăng video lên **Facebook Page qua Graph API** — không mở trình duyệt, không nhập
mật khẩu, không cần điện thoại.

1. Mục **Tài khoản Facebook**: bấm **Connect Facebook** → mở link đồng ý → cấp
   quyền → quay lại. **Kiểm tra kết nối** để đọc lại tài khoản và danh sách Page.
2. Nếu đăng nhập không tự quay về: mở accordion **Nếu đăng nhập không tự quay về**,
   dán nguyên địa chỉ trên thanh địa chỉ vào ô rồi bấm **Hoàn tất kết nối**.
3. Mục **Các Page**: tick **Đăng lên những Page này**. Page không có quyền tạo nội
   dung bị bỏ khỏi danh sách, có dòng đếm.
4. Mục **Các video**: dán chú thích cho mọi dòng (hoặc để AI viết), thêm video từ
   máy hoặc từ thư viện.
5. Mục **Chạy**: chọn **Đăng dưới dạng** (Tự chọn theo từng video / Luôn là Reel /
   Luôn là video thường), bấm **Bắt đầu đăng**.

**Kết quả ở đâu:** bài trên Page. Bằng chứng ở
`logs/social/facebook/<batch>/<nn_video>/`.

**Cần gì trước:** App ID và App Secret dán ở màn Cấu hình, Redirect URI đã khai
trong dashboard Meta, và ba quyền ở [mục 3.4](#34-facebook-app-id-và-secret--chỉ-khi-muốn-đăng-reels).

> **Giới hạn của Facebook.** Bảng chỉ có 3 cột **Xoá / Đường dẫn video / Chú
> thích** — **không có cột Page**, vì Page chọn một lần cho cả lô. **Không có ô
> chỉnh thời gian chờ giữa các bài** — mặc định 30 giây và không đổi được từ giao
> diện. Facebook cho **30 Reel mỗi Page trong 24 giờ**; vượt thì có cảnh báo nhưng
> **không chặn**.

### 4.9 Link từ kênh — nhóm *Kho của bạn*

Không tạo video, không tải gì: nó **liệt kê link video công khai của một kênh**
YouTube hoặc TikTok thành một danh sách sửa được.

1. Dán **Link kênh**.
2. Đặt **số video tối đa** (1–200, mặc định 20) và tuỳ chọn **Lấy cả Shorts** (chỉ
   YouTube).
3. Bấm **Lấy danh sách video**.
4. Danh sách đổ vào ô text — **sửa hoặc xoá tuỳ ý** trước khi dùng.
5. **Lưu danh sách thành file**, hoặc bấm **Gửi sang tab Lồng tiếng**.

**Cần gì trước:** mạng. Không cần khoá AI.

> **Nút gửi sang Lồng tiếng làm gì.** Nó ghi đè ô link của màn Lồng tiếng bằng danh
> sách này và mở màn đó. Nó **không** đặt ngôn ngữ, **không** chọn giọng, **không**
> bấm Dịch — bạn vẫn phải tự chọn ngôn ngữ đích rồi bấm. Và nó **không có kiểm
> tra**: bấm khi ô rỗng vẫn mở màn Lồng tiếng với ô link rỗng.

### 4.10 Tư liệu — nhóm *Kho của bạn*

Đây là **kho nguyên liệu** cho các màn làm video: video nền, nhạc nền, ảnh. Các ô
"Chọn video nền" và "Chọn nhạc nền" ở màn Video ngắn đọc trực tiếp từ kho này —
**kho rỗng thì không màn nào chạy được**.

1. Mở accordion **Thêm tư liệu từ máy bạn hoặc từ YouTube**.
2. Chọn **Thêm từ**: từ YouTube (điền tên, loại, URL) hoặc từ máy (điền tên, chọn
   loại, tải file lên).
3. Bấm **THÊM**.
4. Xem danh sách ở bảng bên trái; bấm một dòng để xem trước; lọc bằng radio **Loại**.
5. **Tải các file về** để lấy các file có thật trên máy — mục chỉ có link YouTube bị
   bỏ qua, không báo lỗi.

**Kết quả ở đâu:** file tải lên được chuyển vào `public/` và ghi vào cơ sở dữ liệu
tư liệu; mục YouTube chỉ là một dòng link. Tên chỉ được chứa chữ, số, khoảng trắng,
`_` và `-`; trùng tên bị từ chối.

### 4.11 Thư viện video — nhóm *Kho của bạn*

Không tạo gì. Đây là **sổ ghi những video đã làm xong, từ cả bốn màn** — thứ duy
nhất trong app trả lời "tôi đã làm gì, file ở đâu".

1. Gõ vào ô **Tìm kiếm** — tìm ngay khi Enter.
2. Lọc bằng **Loại video** và **Sắp xếp** — đổi là bảng đổi ngay.
3. Đọc bảng: **Loại video / Tên file / Thư mục / Ngày tạo**.
4. Chọn một video ở dropdown rồi bấm **Xem trước** để xem ngay trong màn.
5. **Tải tất cả** để lấy zip của *những dòng đang hiện* và *còn file trên đĩa*.

Cột **Thư mục** là thư mục trên máy bạn, không phải chỗ đã "lưu" — việc tải về là do
trình duyệt quyết định. Dòng có file đã bị dọn **vẫn nằm lại** và ghi rõ "file không
còn". Chỉ vẽ tối đa **200** dòng; quá thì phải lọc.

### 4.12 Cấu hình — nhóm *Ứng dụng*

Nơi duy nhất để dán khoá. Chi tiết đầy đủ ở [mục 3](#3-khoá-và-cấu-hình).

### Dùng chung ở nhiều màn

- **Hàng tải cuối màn** — nút **Tải tất cả** (chỉ bật khi có kết quả) và **Xoá kết
  quả trên màn hình** (ẩn ở màn Thư viện). Nhãn đổi theo màn: "Lưu danh sách thành
  file", "Tải ảnh về", "Tải các file về".
- **Thẻ video** — di chuột là **phát im lặng** để xem trước; bấm vào mở trình phát
  nổi (Esc để đóng); mỗi thẻ có nút tải riêng không cần mở trình phát.
- **Nút bàn giao** *Đưa sang Shopee* / *Đưa sang Facebook* có mặt trên **5 màn**.
  Bấm là ghi thẳng vào bảng của màn nhận và mở màn đó.

---

## 5. Quy trình mẫu

### A. Từ một chủ đề ra video ngắn

1. **Tư liệu** → thêm ít nhất một **video nền** và một **nhạc nền**. Không có thì
   màn Video ngắn không chạy được.
2. **Cấu hình** → dán khoá DeepSeek, bấm *Kiểm tra kết nối*, lưu.
3. **Video ngắn** → chọn số video, kiểu video và chủ đề.
4. Chọn giọng đọc và tốc độ.
5. Chọn video nền, nhạc nền, số ảnh mỗi video.
6. Bấm **Tạo video ngắn**. Theo dõi ở bảng 🔀 nếu muốn.
7. Tải về, hoặc bấm *Đưa sang Shopee* / *Đưa sang Facebook*.

### B. Từ một video dài ra nhiều clip ngắn

1. Chép phim dài vào thư mục `input/` trên máy bạn (đừng tải lên — phim nặng hàng
   GB).
2. **Cắt highlight** → nguồn *File trong máy* → chọn phim → bấm *Làm mới* nếu chưa
   thấy.
3. Đặt số lượng highlight và số giây mỗi đoạn. Chọn khung hình **Dọc 9:16** nếu
   đăng mạng xã hội.
4. Bấm **Tìm highlight**, rồi chờ. Phim càng dài càng lâu — đây là bước lâu nhất.
5. Xem từng đoạn, **bỏ tick** những đoạn không dùng, chỉnh *Vị trí cắt* nếu chủ thể
   bị lệch khỏi khung dọc.
6. Bấm **Tạo các đoạn đã chọn** để cắt và lồng tiếng.
7. Tải về, hoặc đưa sang Shopee/Facebook.

### C. Lồng tiếng một video nước ngoài

1. **Cấu hình** → có khoá AI.
2. **Lồng tiếng** → nguồn *Link video*, dán link (mỗi dòng một link), hoặc chọn
   file.
3. Chọn engine đọc. Muốn tiếng không rời khỏi máy thì chọn **ZeroTTS** (chỉ tiếng
   Việt, không cần khoá).
4. Chọn ngôn ngữ đích trong panel của engine, chọn giọng, đặt tốc độ đọc.
5. Tick *Ghi phụ đề lên video* nếu muốn phụ đề cháy cứng.
6. Bấm **Dịch**.

### D. Đăng lên Shopee

1. Cắm điện thoại, bật USB debugging, mở app Shopee và **đăng nhập**.
2. Chuẩn bị video **tối thiểu 576p** — thấp hơn thì Shopee từ chối lặng lẽ.
3. Lấy link sản phẩm: trong app Shopee mở **đúng trang sản phẩm** → Chia sẻ → Sao
   chép liên kết. Link **danh mục** không dùng được — hệ thống chặn và nói rõ lý do.
4. **Shopee** → chọn thiết bị, dán link và chú thích, thêm video.
5. Đặt **giây giữa hai lần đăng** — đừng để nhỏ.
6. Bấm **Bắt đầu đăng hàng loạt**, rồi theo dõi ở bảng Tiến độ.

### E. Giao việc bằng câu lệnh

1. Bấm **🤖** ở thanh ray.
2. Gõ việc bằng câu của bạn — ví dụ "dịch video này sang tiếng Việt", hoặc bấm một
   chip ví dụ để điền sẵn.
3. Enter để gửi. Trợ lý gọi công cụ thật và vẽ từng bước trong khung chat.
4. Việc nó khởi động hiện luôn trên bảng **🔀**.

Muốn kiểm chứng trợ lý nói thật hay không: mở `logs/agent/<giờ>.jsonl`. Lượt gọi
công cụ thật có `"kind": "call"`; chỉ có `"kind": "say"` nghĩa là nó tự viết ra.

---

## 6. Điều khiển từ Telegram (tuỳ chọn)

Cùng những luồng đó, gõ từ điện thoại. Bật một lần:

1. Trong Telegram, nhắn **@BotFather** → `/newbot` → làm theo hướng dẫn, nó trả
   về một token.
2. Nhắn **@userinfobot** để lấy **id số** của bạn.
3. Mở app → màn **Cấu hình** → khối **Bot Telegram** → dán cả hai → **Lưu**.
4. Dựng container của bot **một lần**:
   `docker compose --profile telegram up -d`

   Máy đã cài AutoReel từ bản trước: service này mới được thêm vào
   `docker-compose.yml` ở bản hiện tại. Chạy **AutoReel-Setup bản mới một lần**
   (tự cập nhật chỉ thay image, không thay file compose), rồi mới bật bot.

Rồi nhắn `/start` cho bot. Câu lệnh: `/menu`, `/help`, `/reup`, `/review`,
`/affiliate`, `/jobs`, `/status [mã]`, `/pages`, `/cancel`.

**Bot không tự làm gì cả.** Nó viết một dòng vào database, app đọc dòng đó rồi
gọi đúng thứ mà màn hình vẫn gọi — nên tắt bot giữa chừng không làm chết việc
đang chạy.

**Đọc `/jobs` thế nào.** Mục *Đang chạy* liệt kê mọi việc đang làm, và mỗi task
render hiện **tên sản phẩm kèm phần trăm** — `⏳ AutoReel Engine · Đang dựng
video · 40% · Áo thun nam cotton` — chứ không phải một dãy mã. Mục *Vừa xong*
là những gì đã chạy xong, kèm tên, nên chạy một lượt rồi hỏi lại là thấy nó.

**Theo dõi một lượt đang chạy** bằng `/status <mã>`. Tin nhắn này **tự đổi theo
bước**: đọc link → lấy ảnh → viết kịch bản → dựng video → xếp hàng đợi đăng.
Nếu nó đứng im ở "Đang chạy…" quá lâu thì đúng là đang ở bước đó lâu thật.

**`/status` trần** (không có mã) nói bốn thứ còn sống hay không: ứng dụng,
engine, điện thoại, Facebook. Dòng engine ghi `Sẵn sàng` là dựng video được;
nó không in địa chỉ nội bộ, vì địa chỉ đó không nói được gì với người đọc.

**Ba điều nên biết:**

- Bot **chỉ trả lời những id trong danh sách trắng**. Danh sách rỗng thì nó
  từ chối chạy và in lý do ra `docker logs autoreel-telegram`.
- **Một lệnh đang chạy mà app tắt thì thành `failed` và không chạy lại** — chạy
  lại có thể đăng hai lần.
- `/affiliate`, `/reup`, `/review` có thể **đăng thật**. Phần tóm tắt trước khi
  chạy in rõ sẽ dựng mấy video và đăng lên đâu; chưa bấm Chạy thì chưa có gì xảy ra.

---

## 7. Khi có trục trặc

### Khoá dán vào rồi mà không ăn

Chín trên mười lần là do **một giá trị cũ nằm trong `.env`**. Với mọi khoá trừ
Facebook, ô nhập ở màn Cấu hình mới là cái thắng — nên nếu nó vẫn không ăn, thì
ngược lại: có thể bạn đang sửa `.env` mà quên `docker compose up -d` để container
nhận lại. Xem bảng ở [mục 3.8](#38-khi-một-khoá-nằm-ở-hai-nơi).

Với **Facebook thì luôn kiểm tra `.env` trước** — ở đó `.env` thắng, ngược với mọi
khoá khác.

### Video bị thiếu cảnh

Thiếu **khoá Pexels**. Không có khoá thì tính năng không báo lỗi — nó chỉ trả về
video không có cảnh quay. Dán khoá vào màn Cấu hình và **Lưu**, rồi nhìn dòng trạng
thái bên dưới để chắc khoá đã được gửi sang.

### Facebook: kết nối được, vài ngày sau mới báo thiếu quyền

Đúng cái bẫy ở [mục 3.4](#34-facebook-app-id-và-secret--chỉ-khi-muốn-đăng-reels).
App chưa bật quyền trong use case, nên Meta đã âm thầm bỏ nó ra khỏi lúc xin quyền.
Vào **Use cases → Customize → Permissions and features**, bấm **Add** cho từng quyền
tới khi `Ready for testing`, rồi **Connect Facebook lại**.

Câu báo lỗi trong app có ghi sẵn đúng các bước này.

### Facebook: Connect báo lỗi redirect

Redirect URI trong **Facebook Login → Settings** phải khớp **từng ký tự** với:

```
http://localhost:31415/facebook/callback
```

Sai **số port** cũng bị từ chối, và câu báo lỗi đọc như thể sai đường dẫn. Nếu bạn
đổi port app thì phải sửa cả hai nơi.

Nếu Meta vẫn từ chối `http://localhost`, dùng đường dự phòng: dán code thủ công.

### `AutoReel Engine: không kết nối được`

Bộ máy tạo video chưa chạy. Kiểm bằng:

```bash
docker compose ps
```

Nó là **hai service riêng** trong cùng file compose, không phải container phụ của
app chính.

### Container không chịu khởi động, báo `could not select device driver`

Bạn đang chạy **file compose có khai GPU** trên một máy chưa có NVIDIA Container
Toolkit. Docker dừng ngay lúc tạo container và **không cảnh báo trước**.

Đây là lý do file `docker-compose.yml` gốc **cố ý không khai GPU** — máy không có
card vẫn phải chạy được. Muốn dùng GPU thì dùng riêng `docker-compose.nvidia.yml`,
và khi đó máy phải có driver NVIDIA đủ mới.

### Đang chạy job mà khởi động lại container

**Job chạy bên trong tiến trình của app**, không phải trong trình duyệt. Nghĩa là:

- **Đóng tab thì job vẫn chạy.** Không sao cả.
- **Restart container thì job đang chạy bị huỷ.** Hàng đợi bị đóng và các job chờ bị
  bỏ.

Nên: chạy xong rồi hãy `docker compose restart`, và đừng restart giữa một lượt dịch
nhiều video.

### Đĩa đầy

Biểu hiện **không phải** một câu "hết chỗ" — nó là **lỗi render**. Nếu mọi thứ đang
chạy tốt rồi tự nhiên render hỏng, kiểm tra đĩa trước khi nghi ngờ gì khác:

```bash
docker system df
docker builder prune     # cache build, xoá được, vài GB
```

Chỗ tốn nhất thường là thư mục chứa video sinh ra — video đã dựng xong và không dùng
nữa thì xoá được.
