Shader "UI/RoundRect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Radius("Radius", Range(0,0.5)) = 0.1
		_Color("Color", Color) = (1,1,1,1)
		[Toggle(ColorAdditive)] _ColorAdditive("Color Additive",Int) = 1
		[Toggle(All)]_All("All Round", Int) = 1
		[Toggle(LeftTop)]_LeftTop("Left Top", Int) = 0
		[Toggle(RightTop)]_RightTop("Right Top", Int) = 0
		[Toggle(LeftBottom)]_LeftBottom("Left Bottom", Int) = 0
		[Toggle(RightBottom)]_RightBottom("Right Bottom", Int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float2 radiusUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Radius;
			fixed4 _Color;
			int _All;
			int _LeftTop;
			int _RightTop;
			int _LeftBottom;
			int _RightBottom;
			int _ColorAdditive;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.radiusUV = v.uv - float2(0.5, 0.5);
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}

			fixed4 drawWithoutCorner(v2f i): SV_Target {
				fixed4 col = tex2D(_MainTex,i.uv);
				if(_ColorAdditive == 1) 
				{
					col*=_Color;
				}
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}

			fixed4 draw(v2f i) : SV_Target 
			{
				float2 uv = i.radiusUV;
				float r = 0.5 - _Radius;

				if(abs(uv).x < r || abs(uv).y < r)
				{
					if(_All == 1) 
					{
						return drawWithoutCorner(i);
					}
					else 
					{
						if(_LeftTop == 1 && uv.x < 0 && uv.y > 0)
						{
							return drawWithoutCorner(i);
						}
						if(_LeftBottom == 1 && uv.x < 0 && uv.y < 0)
						{
							return drawWithoutCorner(i);
						}
						if(_RightTop == 1 && uv.x > 0 && uv.y > 0)
						{
							return drawWithoutCorner(i);
						}
						if(_RightBottom == 1 && uv.x > 0 && uv.y < 0)
						{
							return drawWithoutCorner(i);
						}
					}
				}
				bool isDiscard = false;
				bool shouldDiscard = length(abs(uv) - fixed2(r, r)) > _Radius;
				if(_All == 1) 
				{
					isDiscard = shouldDiscard;
				}
				else 
				{
					if(_LeftTop == 1 && (uv.x < 0 && uv.y > 0))
					{
						isDiscard = shouldDiscard;
					}
					if(_LeftBottom == 1 && uv.x < 0 && uv.y < 0)
					{
						isDiscard = shouldDiscard;
					}
					if(_RightTop == 1 && uv.x > 0 && uv.y > 0)
					{
						isDiscard = shouldDiscard;
					}
					if(_RightBottom == 1 && uv.x > 0 && uv.y < 0)
					{
						isDiscard = shouldDiscard;
					}
				}
				if(isDiscard == false)
				{
					return drawWithoutCorner(i);
				}
				else
				{
					discard;
				}
				return  fixed4(0,0,0,0);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return draw(i);
			}
			ENDCG
		}
	}
}
