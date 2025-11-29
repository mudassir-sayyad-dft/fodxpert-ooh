const htmlD = '''<!DOCTYPE html>
<html lang="en">

<head>
  <script type="text/javascript" src="data.json"></script>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=0.4" />
  <title>Ritik Birthday</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css?family=FontName" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">

  <style>
    * {
      box-sizing: border-box;
    }

    @font-face {
      font-family: "Virtual";
      src: url("./font/Virtual-Regular.ttf") format("truetype");
      font-weight: normal;
      font-style: normal;
    }

    body,
    .body {
      margin: 0;
      padding: 0;
      width: 1080px;
      height: 1920px;
      max-width: 1080px;
      max-height: 1920px;
      position: relative;
      background-color: #fff;
    }

    #MessageViewBody a {
      color: inherit;
      text-decoration: none;
    }

    p {
      line-height: inherit;
    }

    .desktop_hide,
    .desktop_hide table {
      mso-hide: all;
      display: none;
      max-height: 0px;
      overflow: hidden;
    }

    .image_block img+div {
      display: none;
    }

    /* Start - Template specific custom CSS */
    .template-container {
      table-layout: fixed;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
      background-color: #171717;
      width: 1080px;
      height: 1920px;
      max-width: 1080px;
      max-height: 1920px;
      overflow: hidden;
      zoom: 1;

    }

    .template-container .template-container-column {
      width: 100%;
      height: 100%;
      vertical-align: top;
      overflow: hidden;
      zoom: 1;
    }

    .bg-image .bg-image-column {
      width: 100%;
      height: 100%;
      vertical-align: top;
      overflow: hidden;
      zoom: 1;
    }

    .content-wrapper {
      color: #ffffff;
      margin: 0 auto;
      width: 100%;
      height: 100%;
      table-layout: fixed;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
      overflow: hidden;
      zoom: 1;
    }

    .content-wrapper .content-wrapper-column {
      font-weight: 600;
      text-align: left;
      padding: 0;
      vertical-align: top;
      border: 0;
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
      zoom: 1;
    }

    .resto-info {
      width: 100%;
      height: auto;
      table-layout: fixed;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }

    .birthday-text {
      font-size: 220px;
      color: #3d342b;
      font-weight: 100;
      font-family: FontName;
      text-overflow: ellipsis;
      overflow: hidden;
      white-space: nowrap;
      text-align: center;
      position: absolute;
      bottom: 10%;
      right: 33%;
      width: 500px;
      z-index: 25;
      animation-delay: 5s;
    }


    /* End: Template specific custom CSS */
  </style>
  <script>
    function clickMe(section) {
      if (!section) {
        return;
      }
      var s = section.includes(":") ? section.split(":")[0] : section;
      console.log(s);
    }
  </script>
</head>

<body class="body">
  <table border="0px" cellpadding="0" cellspacing="0" class="template-container">
    <tbody>
      <tr>
        <td class="template-container-column">
          <table align="center" border="0" cellpadding="0" cellspacing="0" style="
                table-layout: fixed;
                vertical-align: top;
                width: 100%;
                height: 100%;
                position: relative;
              ">
            <!-- Background Video -->
            <div>
              <video id="BG_VIDEO_ID" autoplay muted  loop playsinline style="
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
                object-position: center;
                z-index: 0;
              " src="BG_VIDEO" type="video/mp4" ></video>
            </div>
            <tbody>
              <tr>
                <td class="bg-image-column">
                  <!-- Start: BG Image 2 Header -->

                  <!-- Start: BG Image Header -->
                  <table align="center" border="0" cellpadding="0" cellspacing="0" class="content-wrapper"
                    role="presentation">
                    <tbody>
                      <tr>
                        <td class="content-wrapper-column">

                          <table onclick="clickMe('RESTO_INFO')" border="0" cellpadding="0" cellspacing="0"
                            class="resto-info" role="presentation" style="width: 100%;">
                            <tr>
                              <td>
                                <div>
                                  <!-- <img alt="Yourlogo" id="LOGO" src="LOGO" style="
                                          display: inline-block;
                                          border: 0;
                                          width: 213px;
                                          height: 211px;
                                          position: absolute;
                                          left: 19%;
                                          top:17%;
                                          cursor: pointer;
                                          object-fit: cover;
                                          z-index: 4;
                                          object-position: center;
                                          
                                          " /> -->
                                </div>
                              </td>
                            </tr>
                          </table>

                          <table onclick="clickMe('BIRTHDAY')" border="0" cellpadding="0" cellspacing="0"
                            role="presentation" style="width: 100%;">
                            <tr>
                              <td style="display: flex; justify-content: center;">
                              
                                <img alt="Birthday Image" id="BDY_PHOTO_1" src="BDY_PHOTO_1"
                                  class="animate_animated animate_flipInX" style="
                                     display: inline-block;
                                     border: 0;
                                     width: 832px;
                                     height: 920px;
                                     position: absolute;
                                     object-fit: cover;
                                     object-position: center;
                                     border-radius: 20px;
                                     top: 34%;
                                     animation-delay: 2s;
                                     z-index: 5;
                                     " />

                                <img alt="Birthday Image" id="BDY_PHOTO_2" src="BDY_PHOTO_2"
                                  class="animate_animated animate_flipInX" style="
                                      display: inline-block;
                                      border: 0;
                                      width: 832px;
                                      height: 920px;
                                      position: absolute;
                                      object-fit: cover;
                                      object-position: center;
                                      border-radius: 20px;
                                      top: 34%;
                                      animation-delay: 7s;
                                      z-index: 10;
                                      " />

                                <img alt="Birthday Image" id="BDY_PHOTO_3" src="BDY_PHOTO_3"
                                  class="animate_animated animate_flipInX" style="
                                      display: inline-block;
                                      border: 0;
                                      width: 832px;
                                      height: 920px;
                                      position: absolute;
                                      object-fit: cover;
                                      object-position: center;
                                      border-radius: 20px;
                                      top: 34%;
                                      animation-delay: 11s;
                                      z-index: 15;
                                      " />

                                <img alt="Birthday Image" id="TEXT_BG" src="TEXT_BG"
                                  class="animate_animated animate_bounceIn" style="
                                      display: inline-block;
                                      border: 0;
                                      width: 867px;
                                      height: 300px;
                                      position: absolute;
                                      object-fit: cover;
                                      object-position: center;
                                      border-radius: 20px;
                                      bottom: 8%;
                                      right: 16%;
                                      animation-delay: 4s;
                                      z-index: 1;
                                      " />


                                <!-- Birthday title  -->
                                <img alt="Birthday Image" id="BDY_TITLE" src="BDY_TITLE" style="
                                display: inline-block;
                                border: 0;
                                width: 785px;
                                height: 436px;
                                position: absolute;
                                object-fit: cover;
                                object-position: center;
                                border-radius: 20px;
                                top: 10%;
                                " />

                                <!-- birthday text  -->
                                <div class="birthday-text animate_animated animate_bounceIn" id="BDY_TEXT">BDY_TEXT
                                </div>
                              </td>
                            </tr>
                          </table>

                          <!-- bow logo -->
                          <!-- <table border="0" cellpadding="0" cellspacing="0" role="presentation" width="100%">
                            <tr>
                              <td>
                                <div>
                                  <img alt="footer-fodex-logo" src="fodx-logo-black.png" title="Footer Fodex Logo"
                                    style="
                                    width: 145px;
                                    height: 85px;
                                    position: absolute;
                                    bottom: 16%;
                                    left: 21%;
                                    " />
                                </div>
                              </td>
                            </tr>
                          </table> -->

                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    </tbody>
  </table>
</body>
<script type="text/javascript" src="getParams.js"></script>

</html>''';
