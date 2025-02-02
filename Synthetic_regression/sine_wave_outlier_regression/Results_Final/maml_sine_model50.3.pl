��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1399765742208qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1398710235520qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1398710232736qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1398710235808q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1398710231008q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1398710235904q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1398710231008qX   1398710232736qX   1398710235520qX   1398710235808qX   1398710235904qX   1399765742208qe.(       ��ͼkq<F�E>���>�!5�B��O0ο5"��	���^n�A;	�+tq�r��>��>;Z���_>"��z��>����6N�H@���6q?Y�����>R�q��ܾ��->E��N�=�>��˽�W=���@=�?����%D�>2�x�O<,>�B�>D�?�@      ��	>`���7!��^��̟�=.�轠b��,�3{ɽ��P�y�̏8�)�<�S<½�=~[�=����kt,��<6�z&P��)��м��`�:��=��<�AM=f#�<�RI=�g�
8=�ũ�=�5=�_.�� l����P̽g���ܑ=j���h�<�ё��D�=򸋾����O�=ehm��w����R���پ���߄=�@L� ���9e:�����׳����;��C�����4̾��¼���<���;iG���=w#�����=Ž��ǳ���*��t���>'���I��ӿ��k�U��Xj���eZ�-�>](�=rMC=e4�n��>��?j�9��Qq�Ms�<x��$�Q>i��?�v�=�н���wz���ӕ=�S���2a?y�=5�ƾ`��E��>1`>��B�����Y7�y׆>A	ϼ����6�z=H�>����>�͊��D��P?ڕ�=�1�v�A�
�M>�O=#�������;����w=���.�Lg\���^=$�i������ᾶ�:$�1����OW�=��>`뭾/4�?��R>�& �<�ݽ�7ֽ�-��;��ޓ*�w����i�=��=<��տ*�½{g�?1g-=j ͼvƔ������6��z���@��]�}�|�Ū ���p>��ÿ9����B�V�k�CcԽ�h#�~悾En@�<�;�E��("?�J�����>�z���
�v�@��'?�<��M��&;���?����r��d��=�ُ�Zr���#�?�+1�(v=>p~�=�#4?
7c?���<�?�Rο�潘������m����L�G���q<n��=�~�D�/�hoS�[���醿E�j�@���M��7��{�p���Ҿݫ���4��~�P�A����\�b6��e�(�Cޝ>+p�����>x3�Re>8�@?^�%��{7>�����&I�;X�?��ؾdcv�>/ƽ<�����=?-L���Ώ��=�L	�:ѿ'��>Nþ���<B��04g�2县	d?�8��]���
����<Z�>�څ?�y�|m���"��+ >CC9�+ߜ��Ͽ�����ݿm��ۆT?=�ſ�?�HF�oY���l��3*߾�
�G�[�L�ƾev���1�>s���#�;�͋������1>a�N�l��ue��3�=�P�>���>���u,�<������>N	��5�����?Lv>.�V��|ڽ_@���(<@+>�H���0?y�$�%���pv�>�P>rT���@�����;q�Q�e=�.
>O��̿mZ�=�}�
�4�'�?z-?*�"��c�>�$?G7��ʺ��ѽ�>l��,j>�����P�&���`:�(���6?}���K����>�t�`�?~�h��nV��;�V^�>�h��x��7�*�o�}��>���=t�c�/��?��o��K��%\Ӿ�j{�Y���x����׼W3�:�=AG��b�<"(�zu9<�`L�����]��/��<����`gֽP7l<���R��q#��G�*X�=C�"���=A9?�p�ֽɺҳ�3bD���e�Ԓ\��7����������=%rE�82$��K���pF�j���� >ȅ�=�*�8�������-����>�i��(�<���=�Z��še>��>A�{?h������<ݱ�+T=?A ?�-�6��<�=�x�=}�>J?~��ۏ�Y{ԼAp<?�?{�@>H�8>�D�=+��>�	���ѿ=$�=�ža0�>f�>*2�>D�=i3*>� ���=�l��Bkv�H+���}=�m�<E���*�=v0��Ѕ<nN>ć5��/��!�ɼM��=N�.�4[�R�T��.��0����=gh^��������;��=�x�<?���"ڼ�[�J�X����7ֽ<�yU=�3���(r<E�ƽ9m��d!���>#>�W==�>�>�R�9#����?�}p>k�3>(��>�K�!,�;d�(?�j@>�[?#*�>Yt>���>�/��ug�>�r>���<�̄=�I��v �h��p�W?`�x��w{>��,�>2!>�սa&���C�>��	@����h��>�c?$���v�m�0=�_����:=��K?Y䁾��D��?JP��H>���q!?������	>ίi>�i,>�$�>ҼYJi?UT�>Dir>b��`� =r�R�1�ݽ�1���;��>.���
۾Q����\���7+���j?�c����P>��0�cs5����=-��6���13���+�c鰾C�>�&�k,>��>�B�]S�= E>�d����/?�4?�p�>/k.>҉��>f���6j��N�>�a�h�>����z}�=���?��>?׾�d�>��Z?-�j��4>H�`����PǠ�3p�>�Oc>J����>�T�V�w>G(�<�PU�ʳ�=��Q�T�'>\��='���#�Z[?�c �b�;6��pB��F�L�@`M>�]o>r}�>�5>��>TH/?Yő?ڒ>��`=��\<3��vց��ſ�-���gQ�#�m��6��>=d��1Ob?�M>�2�=Z��>�>���>��J����t��0�2=�K=a���b��=�>�<^�=� ˽H���D����2/�;\�7�x��G��=lq��遽�"=���BZ��گ�h�=��(=Q!��1��-g|�K 5�E���ȡ���I�s���B��=pys=�"�t=�C8�+���ƣ�������ҽ�Y�<Rc�� E;d?q���?a?뮑?��9��e�8�þ��=5�$?5�A?���n�=��ƾ1�����v緿�3j?��D>�M�>�̈=���AH? ��?��>@�@��<?fN��w?�.x>|w�����=x��>X�ɿ�~4�T��?,KC�^���#�?�W;�M� ��0��������>k���㗊��fu=��=� ����<��V�����^���E?ɼ)?��ƾ�,4>� ��(��ΐ�=�	ѿ�Y־�L[>m"�>R?�]�<z8����?q઻��A�ڳ?�Yﰾ��U������r0P��[��%Y=6S��R��=md>�PF����u�w>?Ͽ��>êo����u��=D�?�6=��1>������?�L+��5@���@�t�>x{_��Խ���%�pԻ$��UQ?��)��f�>��T�9�>��G� �]�2˷=!�)�9L�>�/�=�|?��=H��%x����`��4���3��x7>��D=���F)j���Z�$4��i���[�<?�P����+�>Ou�>��>�
�����+F��z�,�k����YǼVm�>���;��2?[i��_�&���>lw¾�}�}S�=�yR��y�>4Ԇ>���<�%O�� Ⱦ�(���8����=�Ս=J?��߾��뾮�&��Aо���=.:�;��N"�>�b��9e����</wC�|kq=�ܑ�7�?t��>;NZ����=����O���`�f4]�s�3?�"���jK�9�?I����>���`�����>�+�?�qV=� ���Ͼ���B9��� >B����A�*��=�����O�5����;(������ʽ���=u`���=��
�'�
�����D�s�f��ݵ̽���[�=1�<��C�=6Ջ��$���ֺWu����=D���V���	�s�)��q��_�=; �B=�E�����ϓ&�`�Q?T���-�>{:N��O ��>�ܓ=:콽]:�>��>S��=�c?�s����`���b#�Z>�O���H�<m2�= I~<��J?�O��Q������1���>���>?e�:�~>���6<�l�ǽ\U�?Ğ��"׾�0?q'u>SO��H��hY޾o��=�)}?Y=/���ƾ��U?�⿾њ��B�z�8�?̈+�s�?�g@�D�>����Y��δ�?%?���>OP��"��=��	?o1�ŏ(�ѕ��?կ��g���i��w��@?��l�?I���,��+<���C��=�e��l~̿���̚�D�=�.�>̱����=�6j=uտZ�ҽ�
>"���>���>�gs��9�=(kྨ�>/��<3�W�þ����U?�'ʓ���;�.�W<g��>J���W�@?c)�����7�?�}�����b��A>�F�9��=���<��C��M��ϥ���K�4�=��o�7�۾Ĩ��z)�)�����R�c�C>%��b�齄`�����/�̽���=Q:�~���	�j�=�\p�C�>�>ni=*��D�����u�)��!?����8�W`;[Z�<�c)���1��ł=Ͽѽ�Իr��a����!�kb*���zv>���ӑ�>�͗>K�p�U�ལ�w��8�̑�>��?�����LV=��}�^������,{��ѣ�����=�ٽ[���l;�M4�>O��b}>�=��������>��8�\�z��(.�ߨ�=���J�T>8�>>-�����I�*��>�ɘ���=̋̽�`[��^���Ȏ=W~ �a��=M�ӽ-l��[�`���:���=�&N��Y�����=�12�)�*����9O=@�(��[R��H��1�� �F�;R-���2�����S�<�Y��A�`<s���<0��屿=���mN=dS*��"���ȋ=�o>,����=۾�5?�dw�M�̾E� =/����{�>깅>�8��m�=�:>�-�?��%?F�>���������m��'��VΈ�9x�����F 2���6�+��Wu?<�꾙>�!�>|t���a�;=[I=v�K:Cj�'<��=H���z��A=�j$�B���̍��D=QC����Y��k�ȼ)�ۼP���4���j�E&i�Q�C���:�]���漻쁽C����M�*P�<�:��Ư���ϼnNq�"�n�o��ȍ�(���J�����+�k��(�;��۽(�`�o  �8A1�_N<�/#ӿ�9����=��=v���E�B<⇿�p���]�sj�xӏ<������4>��V��҃���þw�>(0���ȽenT����<K���h.?x	��m���|��QKD���娽��xD���Ɇ=ji��@Ծj�E�Em��%D��J��,8��#?�a8?'t�<���>[�Y���4�)ԽK��>ȼ�>zޅ��\���3��}��~XC���-�S�⿑ҿ��5>G>���>)>"���uM��J�>%as�G�e��=L�'�������۽�B̾ÿ��>����e�Ͽ/I<��|�,NP>-��=VCƽ���m�8IM>�8^>���R�>2\�>G�h�4��[=US	?�?��>>c�����>3"ҿ/���XW>:��=�X/?N�f>?��l>��q?%<�=kq>��O�g|@>�=p���>@��>E$?޾�:�=�6�>�(u>�\�>�yt�uJ>�|(�ӡ�><S�_������W�`��ݍ�$o'�u�=w�?��7��mS�6�����7>�S��u)�3y�=~3�!��+���}޽'w����7=�?�<Z�bB�0$v�}C�F-�pz����]��m��K�h�jy�m1H�v�d�L�����f���>�I;��>ߪ ?	��o��-��_�v�?�I��x�>_�[>��ڿ$�>W`�=T���l����:>1�����J�?o��>F����>�>=��X�Ŀ		���+��P8��Y����нjfm>��V��P�?<�ݽ����֠t�^fҾ@��T�q�M�g81?8�N���i�!�C?�b����4��֥>$;<��>�d���_�D��Y?>:6�==l�>@�Ծ�r���Q>���^9%�^�$�EQ�=$`����������B#>��>&a��B���j����U�n��>��5?�	�����>gD��	���P��/���G�i���ӣ�=��(�d�=�~^��.�<J/=/3��������=��I�=���Z���K�<�����>���w% >S߰<;�*:>��=j��=�����=�}�7�)��a0=>�=<VV�=���]!�J�<����a8=�C�e`�y���,/.�c7��7�=)��=�&S>�ҽ:��=�E������?+!��Ў>r@�>1���5�c>/`�g��(Qp����>y�`��(���;�=g?�2�>���>2l��I�>�P>� �=h�<�{�>5a�<KC�=�_��D�9�E�\�j�7�R�=�����4���"�6A���㿇��='�r=3��e{>S	��w���u�ӿ��"��L�$���C�+��HQ>��&?�R0?���A��>!8>]
������>���S���>�����L^?_����G?a¾:��G�3>���5���~=�����o��>(       |��뼛���<�|$?�b�=���>�D�>&��Eƿ�3s��_�=|�?Ȱ�=�?5��Ę��v���[��z�>�B�>~H@=�޽��Z�[�>�Rս-��;�����_F>���
���nx	?�W��<:?$�쿺��|>�6�?4�(�O蒿�$ý�	�(       �`������p;=�bѾvk�>�	�>[e�=ВнF�H>S�u<�6о������ ���վ�x���%7�ò��9�>����#�> ^Ǿ&�Q=��Q:�yͿ�M�>�Ĝ>���[�<�򒾙�ƾ�Y�����e�=D(�����"���?�X��g��u�>       �|1�(       �� ?Ur�M�$>y(���>���>?�Ƚ~0�S��>lh��='.>Oн{��=�J�>��l>�H?<�>��N佫�*>�������xD:=�>�$����>�^S�!�5��hླہ���W��؅=��?�A�>q�m>�����ǜ>��[�uK��w'�