Shader "Unlit/TextureCropShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureAspect ("TextureAspect", float) = 1.0
        _GameObjectAspect("GameObjectAspect",float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _TextureAspect;
            float _GameObjectAspect;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.uv;
                float scale;
                if (_TextureAspect >= _GameObjectAspect)
                {
                    scale = _TextureAspect / _GameObjectAspect;
                }
                else
                {
                    scale = _GameObjectAspect / _TextureAspect;
                }
                uv.x /= scale;
                uv.y /= scale;
                const float offset = (scale - 1.0) / 4;
                uv.x += offset;
                uv.y += offset;
                o.uv = uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}